import Foundation
import Combine

class ChordEngine: ObservableObject {
    @Published var detectedChord: String = "--"
    @Published var confidence: Float = 0.0
    @Published var chromaVector: [Float] = Array(repeating: 0.0, count: 12)
    @Published var candidates: [(name: String, score: Float)] = []
    
    private var allTemplates: [String: [ChordTemplate]] = [:]
    private let audioManager = AudioManager.shared
    private let sampleRate: Double = 44100.0
    
    init() {
        loadDatabase()
    }
    
    private func loadDatabase() {
        let path = "/Users/peterfarell/.gemini/antigravity/scratch/ukule_pro/UkulelePro/Resources/ChordDatabase.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tunings = json["tunings"] as? [String: Any] else {
            return
        }
        
        for (tuningKey, tuningData) in tunings {
            if let dict = tuningData as? [String: Any],
               let chordsData = try? JSONSerialization.data(withJSONObject: dict["chords"] ?? []),
               let templates = try? JSONDecoder().decode([ChordTemplate].self, from: chordsData) {
                allTemplates[tuningKey] = templates
            }
        }
    }
    
    func processFFT(_ fftData: [Float]) {
        guard !fftData.isEmpty else { return }
        
        let newChroma = calculateChroma(from: fftData)
        self.chromaVector = newChroma
        
        // Get templates for current tuning
        let tuningKey = audioManager.tuning.rawValue
        guard let templates = allTemplates[tuningKey] else { 
            DispatchQueue.main.async { self.detectedChord = "--" }
            return 
        }
        
        var results: [(name: String, score: Float)] = templates.map { template in
            return (template.name, template.similarity(to: newChroma))
        }
        
        // Sort by score descending
        results.sort { $0.score > $1.score }
        
        DispatchQueue.main.async {
            self.candidates = results
            if let best = results.first, best.score > 0.6 {
                self.detectedChord = best.name
                self.confidence = best.score
            } else {
                self.detectedChord = "--"
                self.confidence = 0.0
            }
        }
    }
    
    private func calculateChroma(from fftData: [Float]) -> [Float] {
        var chroma = Array(repeating: Float(0.0), count: 12)
        let binCount = fftData.count
        let binWidth = Float(sampleRate / Double(binCount * 2)) // FFT output is N/2
        
        // Map bins to semitones (C0 is ~16.35Hz)
        for i in 1..<binCount {
            let freq = Float(i) * binWidth
            guard freq > 50 && freq < 2000 else { continue } // Filter range for Ukulele
            
            let n = 12.0 * log2(Double(freq) / 440.0) + 69.0
            let noteIndex = Int(round(n)) % 12
            
            // Add magnitude to the corresponding semitone bin
            chroma[noteIndex] += fftData[i]
        }
        
        // Normalize
        let maxVal = chroma.max() ?? 1.0
        if maxVal > 0 {
            for i in 0..<12 {
                chroma[i] /= maxVal
            }
        }
        
        return chroma
    }
}
