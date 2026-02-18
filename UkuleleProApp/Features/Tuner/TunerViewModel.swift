import Foundation
import Combine
import SwiftUI

class TunerViewModel: ObservableObject {
    @Published var currentPitch: Double = 0.0
    @Published var currentNote: String = "--"
    @Published var centsDeviation: Double = 0.0
    @Published var isRunning = false
    @Published var isStrobeMode = false
    
    private var audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var tuning: Tuning {
        get { audioManager.tuning }
        set { audioManager.tuning = newValue }
    }
    
    // Frequency to Note constants
    private let frequencies: [Double] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    private let noteNames: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // Smoothing
    private var pitchBuffer: [Double] = []
    private let smoothingWindow = 5 // Number of samples to average
    private let amplitudeThreshold: Float = 0.05 // Minimum volume to detect pitch
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Combined pipeline: Pitch + Amplitude
        audioManager.$currentFrequency
            .combineLatest(audioManager.$amplitude)
            .sink { [weak self] frequency, amplitude in
                self?.processSignal(frequency: Double(frequency), amplitude: amplitude)
            }
            .store(in: &cancellables)
            
        audioManager.$isRunning
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)
    }
    
    private func processSignal(frequency: Double, amplitude: Float) {
        // 1. Noise Gate: Ignore quiet sounds
        guard amplitude > amplitudeThreshold else {
            // Gradually decay pitch display instead of hard reset? 
            // For now, hard reset if silence persists, but maybe keep last value for a bit?
            // Let's stick to simple gate for now
            return 
        }
        
        // 2. Range Gate: Ignore impossible frequencies for Uke
        guard frequency > 50.0 && frequency < 1000.0 else { return }
        
        // 3. Smoothing Buffer: Moving Average
        pitchBuffer.append(frequency)
        if pitchBuffer.count > smoothingWindow {
            pitchBuffer.removeFirst()
        }
        
        // Calculate average
        let smoothedFrequency = pitchBuffer.reduce(0, +) / Double(pitchBuffer.count)
        
        updateDisplay(frequency: smoothedFrequency)
    }
    
    private func updateDisplay(frequency: Double) {
        currentPitch = frequency
        
        // Pitch to Note Formula: n = 12 * log2(f / 440) + 69
        let n = 12.0 * log2(frequency / 440.0) + 69.0
        let noteIndex = Int(round(n))
        let octave = (noteIndex / 12) - 1
        let noteName = noteNames[noteIndex % 12]
        
        currentNote = "\(noteName)\(octave)"
        
        // Calculate cents deviation
        let frequencyForNote = 440.0 * pow(2.0, (Double(noteIndex) - 69.0) / 12.0)
        centsDeviation = 1200.0 * log2(frequency / frequencyForNote)
    }
    
    func toggleTuner() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        audioManager.start()
    }
    
    func stop() {
        audioManager.stop()
    }
}
