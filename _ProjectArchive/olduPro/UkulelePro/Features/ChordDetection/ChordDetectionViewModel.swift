import Foundation
import SwiftUI
import Combine

class ChordDetectionViewModel: ObservableObject {
    @Published var detectedChord: String = "--"
    @Published var refinedChord: String? = nil
    @Published var confidence: Float = 0.0
    @Published var isInLimbo: Bool = false
    @Published var chromaVector: [Float] = Array(repeating: 0.0, count: 12)
    
    private let engine = ChordEngine()
    private let refiner: ChordRefiner
    private var audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var tuning: Tuning {
        get { audioManager.tuning }
        set { audioManager.tuning = newValue }
    }
    
    init() {
        self.refiner = ChordRefiner(engine: engine)
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Observe tuning changes
        audioManager.$tuning
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
        // Feed FFT data to engine
        audioManager.$fftData
            .sink { [weak self] fftData in
                self?.engine.processFFT(fftData)
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
            
        // Observe refiner results
        refiner.$isInLimbo
            .assign(to: \.isInLimbo, on: self)
            .store(in: &cancellables)
            
        refiner.$refinedChord
            .assign(to: \.refinedChord, on: self)
            .store(in: &cancellables)
    }
    
    var displayChord: String {
        if isInLimbo, let refined = refinedChord {
            return refined
        }
        return detectedChord
    }
}
