import Foundation
import Combine
import SwiftUI

class TunerViewModel: ObservableObject {
    @Published var currentPitch: Double = 0.0
    @Published var currentNote: String = "--"
    @Published var centsDeviation: Double = 0.0
    @Published var isRunning = false
    
    private var audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var tuning: Tuning {
        get { audioManager.tuning }
        set { audioManager.tuning = newValue }
    }
    
    // Frequency to Note constants
    private let frequencies: [Double] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    private let noteNames: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        audioManager.$currentFrequency
            .sink { [weak self] frequency in
                self?.processFrequency(Double(frequency))
            }
            .store(in: &cancellables)
            
        audioManager.$isRunning
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)
    }
    
    private func processFrequency(_ frequency: Double) {
        guard frequency > 10.0 else { 
            currentPitch = 0.0
            currentNote = "--"
            centsDeviation = 0.0
            return 
        }
        
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
