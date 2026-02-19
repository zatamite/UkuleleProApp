import Foundation
import Combine
import Accelerate

class ChordEngine: ObservableObject {
    @Published var detectedChord: String = "--"
    @Published var confidence: Float = 0.0
    @Published var chromaVector: [Float] = Array(repeating: 0.0, count: 12)
    @Published var candidates: [(name: String, score: Float)] = []
    
    // Configuration
    private let fluxThreshold: Float = 0.015 // Much more sensitive (was 0.03)
    private let minAmplitude: Float = 0.08   // Lower gate for soft playing (was 0.12)
    private let latchDelay: TimeInterval = 0.20 
    private let cooldown: TimeInterval = 0.4    
    private let analysisWindowSize = 8192
    
    // State
    private var previousAmp: Float = 0.0
    private var lastTriggerTime: Date = Date.distantPast
    private var analysisTask: DispatchWorkItem?
    private var cancellables = Set<AnyCancellable>()
    
    private var templates: [ChordTemplate] = []
    
    init() {
        refreshTemplates()
        // Note: Engine starts stopped. View must call start().
    }
    
    func refreshTemplates() {
        self.templates = generateAllTemplates()
        LogManager.shared.log("Refreshed \(templates.count) chord templates", source: "ChordEngine", level: .info)
    }
    
    func start() {
        stop() // Clear existing
        setupStrumListener()
        LogManager.shared.log("ChordEngine Started", source: "ChordEngine", level: .info)
    }
    
    func stop() {
        cancellables.removeAll()
        analysisTask?.cancel()
        candidates.removeAll()
        detectedChord = "--"
        chromaVector = Array(repeating: 0.0, count: 12)
        LogManager.shared.log("ChordEngine Stopped", source: "ChordEngine", level: .info)
    }
    
    private func setupStrumListener() {
        // Monitor Amplitude for Strum Onset
        AudioManager.shared.$amplitude
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amp in
                self?.handleFlux(amp)
            }
            .store(in: &cancellables)
    }
    
    private func handleFlux(_ currentAmp: Float) {
        // 1. Calculate Flux (Change in energy)
        let delta = currentAmp - previousAmp
        previousAmp = currentAmp
        
        // 2. Check Triggers
        // Must be loud enough, must be a spike (attack), and must be outside cooldown
        if currentAmp > minAmplitude && delta > fluxThreshold {
            let now = Date()
            if now.timeIntervalSince(lastTriggerTime) > cooldown {
                lastTriggerTime = now
                // UI Feedback: "I heard you"
                DispatchQueue.main.async {
                    self.detectedChord = "--"
                    self.confidence = 0.0
                }
                triggerAnalysis()
            }
        }
    }
    
    private func triggerAnalysis() {
        // Debounce: Cancel any pending analysis that hasn't started
        analysisTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            self?.performHighResAnalysis()
        }
        
        analysisTask = task
        
        // Wait for bloom
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + latchDelay, execute: task)
    }
    
    private func performHighResAnalysis() {
        // Capture buffer directly — getLastSamples returns a value-type copy, safe from any thread.
        let buffer = AudioManager.shared.getLastSamples(count: analysisWindowSize)
        analyzeSnapshot(buffer)
    }
    
    private func analyzeSnapshot(_ buffer: [Float]) {
        guard buffer.count >= analysisWindowSize else {
            return
        }
        
        // 2. High-Res FFT (Accelerate)
        let fftData = computeFFT(buffer)
        
        // 3. Additive Harmonic Chroma
        let (chroma, _) = calculateAdditiveChroma(fftData)
        
        // 4. Template Matching
        var results: [(name: String, score: Float)] = templates.map { template in
            return (name: template.name, score: template.similarity(to: chroma))
        }
        results.sort { $0.score > $1.score }
        
        // 5. Update UI (Main Thread)
        DispatchQueue.main.async {
            self.chromaVector = chroma
            self.candidates = results
            
            if let best = results.first, best.score > 0.6 {
                LogManager.shared.log("Strum Locked: \(best.name) (\(String(format: "%.2f", best.score)))", source: "ChordEngine", level: .debug)
                self.detectedChord = best.name
                self.confidence = best.score
            } else {
                self.detectedChord = "?"
                self.confidence = results.first?.score ?? 0.0
            }
        }
    }
    
    // MARK: - DSP Math
    private func computeFFT(_ buffer: [Float]) -> [Float] {
        var real = buffer
        var imaginary = [Float](repeating: 0.0, count: buffer.count)
        
        let length = vDSP_Length(log2(Float(buffer.count)))
        let fftSetup = vDSP_create_fftsetup(length, FFTRadix(kFFTRadix2))!
        
        // Windowing (Hanning) to reduce leakage
        var window = [Float](repeating: 0, count: buffer.count)
        vDSP_hann_window(&window, vDSP_Length(buffer.count), Int32(vDSP_HANN_NORM))
        vDSP_vmul(real, 1, window, 1, &real, 1, vDSP_Length(buffer.count))
        
        // Compute Magnitudes — use withUnsafeMutableBufferPointer so pointers outlive the call
        var magnitudes = [Float](repeating: 0.0, count: buffer.count / 2)
        real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                vDSP_fft_zip(fftSetup, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(buffer.count / 2))
            }
        }
        
        vDSP_destroy_fftsetup(fftSetup)
        
        var normalized = [Float](repeating: 0.0, count: magnitudes.count)
        var count = Int32(magnitudes.count)
        vvsqrtf(&normalized, magnitudes, &count)
        
        return normalized
    }
    
    private func calculateAdditiveChroma(_ fft: [Float]) -> ([Float], [String]) {
        var chroma = [Float](repeating: 0, count: 12)
        let sampleRate = AudioManager.shared.sampleRate
        let binWidth = Float(sampleRate) / Float(analysisWindowSize)
        
        // 1. Peak Discovery: Find peaks to ignore floor noise
        var peaks: [(index: Int, val: Float)] = []
        for i in 2..<(fft.count-2) {
            if fft[i] > fft[i-1] && fft[i] > fft[i+1] && fft[i] > 0.05 {
                peaks.append((i, fft[i]))
            }
        }
        
        // Sort peaks by magnitude and take top 15
        peaks.sort { $0.val > $1.val }
        let activePeaks = peaks.prefix(15)
        
        // Gaussian Sharpness: 0.15 is much "stickier" and precise than 0.4
        let sigma: Double = 0.15 
        
        for peak in activePeaks {
            let freq = Float(peak.index) * binWidth
            guard freq > 60 && freq < 1500 else { continue }
            
            let continuousNote = freqToContinuousNote(Double(freq))
            
            // Map peak energy with tight Gaussian focus
            for offset in -1...1 {
                let noteBucket = (Int(round(continuousNote)) + offset)
                let distance = Double(noteBucket) - continuousNote
                let weight = Float(exp(-(distance * distance) / (2 * sigma * sigma)))
                
                let normalizedIndex = ((noteBucket % 12) + 12) % 12
                
                // Harmonic Dampening: If this is very high up, it's likely a harmonic.
                // We weight fundamentals (lower notes) more heavily.
                let frequencyWeight: Float = freq < 500 ? 1.0 : 0.6
                
                chroma[normalizedIndex] += peak.val * weight * frequencyWeight
            }
        }
        
        // Final Normalization
        let maxVal = chroma.max() ?? 1.0
        if maxVal > 0 {
            for i in 0..<12 {
                chroma[i] /= maxVal
            }
        }
        
        return (chroma, [])
    }
    
    private func freqToContinuousNote(_ freq: Double) -> Double {
        guard freq > 0 else { return 0 }
        // Formula: n = 12 * log2(f / 440) + 69
        return 12.0 * log2(freq / 440.0) + 69.0
    }
    
    // Removed tuning-specific population as templates are root-relative
    
    private func generateAllTemplates() -> [ChordTemplate] {
        var generated: [ChordTemplate] = []
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Define Formulas (Intervals from Root)
        // Format: (Suffix, [Intervals], [Anti-Weight Intervals])
        let formulas: [(String, [Int], [Int])] = [
            // Triads
            ("",        [0, 4, 7],       [3, 5, 9]),    // Major (Avoid m3, P4, M6 for clean triad)
            ("m",       [0, 3, 7],       [4, 9]),       // Minor (Avoid M3, M6)
            ("dim",     [0, 3, 6],       [4, 7]),       // Diminished (Avoid M3, P5)
            ("aug",     [0, 4, 8],       [3, 7]),       // Augmented (Avoid m3, P5)
            
            // Suspended
            ("sus2",    [0, 2, 7],       [3, 4]),       // Sus2 (Avoid 3rds)
            ("sus4",    [0, 5, 7],       [3, 4]),       // Sus4 (Avoid 3rds)
            
            // Sevenths
            ("7",       [0, 4, 7, 10],   [11]),         // Dom7 (Avoid M7)
            ("maj7",    [0, 4, 7, 11],   [10]),         // Maj7 (Avoid m7)
            ("m7",      [0, 3, 7, 10],   [4, 11]),      // Min7 (Avoid M3, M7)
            ("dim7",    [0, 3, 6, 9],    [4, 7, 10]),   // Full Dim7
            ("m7b5",    [0, 3, 6, 10],   [4, 7]),       // Half Dim
            
            // Extensions (Simplified)
            ("6",       [0, 4, 7, 9],    [10]),         // Major 6 (Avoid m7)
            ("m6",      [0, 3, 7, 9],    [4, 10]),      // Minor 6 (Avoid M3, m7)
            ("add9",    [0, 4, 7, 2],    [3, 10, 11]),  // Add9 (Treat 9 as 2)
            
            // Extended (4-string voicings — 5th dropped)
            ("9",       [0, 4, 10, 2],   [11]),         // Dom9: Root, M3, m7, M9 (no 5th)
            ("maj9",    [0, 4, 11, 2],   [10]),         // Maj9: Root, M3, M7, M9 (no 5th)
            ("m9",      [0, 3, 10, 2],   [4, 11]),      // Min9: Root, m3, m7, M9 (no 5th)
            ("11",      [0, 10, 2, 5],   [4]),          // Dom11: Root, m7, M9, P11 (no 3rd/5th)
            ("m11",     [0, 3, 10, 5],   [4]),          // Min11: Root, m3, m7, P11
            ("13",      [0, 4, 10, 9],   [11]),         // Dom13: Root, M3, m7, M13 (no 5th/9th)
            ("maj13",   [0, 4, 11, 9],   [10])          // Maj13: Root, M3, M7, M13
        ]
        
        // Generate for all 12 roots
        for i in 0..<12 {
            let rootName = noteNames[i]
            
            for (suffix, intervals, antiIntervals) in formulas {
                var chroma = [Float](repeating: 0.0, count: 12)
                var chordNotes: [String] = []
                
                // 1. Set Positive Weights with Music Theory Priority
                for (index, interval) in intervals.enumerated() {
                    let noteIndex = (i + interval) % 12
                    
                    // The Root (Index 0) is the most definitive.
                    // The 5th (interval 7) is the next most stable.
                    var weight: Float = 1.0
                    if index == 0 { weight = 1.3 } // Heavy Root priority
                    else if interval == 7 { weight = 1.1 } // Strong Fifth
                    
                    chroma[noteIndex] = weight
                    chordNotes.append(noteNames[noteIndex])
                }
                
                // 2. Set Anti-Weights (Penalties)
                for interval in antiIntervals {
                    let index = (i + interval) % 12
                    chroma[index] = -0.5 // Moderate penalty (softer than -1.0 to survive real-world noise)
                }
                
                let chordName = rootName + suffix
                generated.append(ChordTemplate(name: chordName, chroma: chroma, notes: chordNotes))
            }
        }
        
        return generated
    }
}
