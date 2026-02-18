import Foundation
import SwiftUI
import Combine

class ChordDetectionViewModel: ObservableObject {
    @Published var detectedChord: String = "--"
    @Published var confidence: Float = 0.0
    @Published var chromaVector: [Float] = Array(repeating: 0.0, count: 12)
    
    private let engine = ChordEngine()
    private var audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var tuning: Tuning {
        get { audioManager.tuning }
        set { audioManager.tuning = newValue }
    }
    
    init() {
        // Refiner removed: High-Res Engine is autonomous
        setupSubscriptions()
    }
    
    func start() {
        engine.start()
    }
    
    func stop() {
        engine.stop()
    }
    
    private func setupSubscriptions() {
        // Observe tuning changes
        audioManager.$tuning
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
        // Observe engine results
        engine.$detectedChord
            .assign(to: \.detectedChord, on: self)
            .store(in: &cancellables)
            
        engine.$confidence
            .assign(to: \.confidence, on: self)
            .store(in: &cancellables)
            
        engine.$chromaVector
            .assign(to: \.chromaVector, on: self)
            .store(in: &cancellables)
    }
    
    var displayChord: String {
        return detectedChord
    }
}
