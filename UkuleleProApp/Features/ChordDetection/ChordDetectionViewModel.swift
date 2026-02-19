import Foundation
import SwiftUI
import Combine

class ChordDetectionViewModel: ObservableObject {
    @Published var detectedChord: String = "--"
    @Published var stickyDetectedChord: String = "--"
    @Published var confidence: Float = 0.0
    @Published var chordHistory: [String] = []
    @Published var chromaVector: [Float] = Array(repeating: 0.0, count: 12)
    @Published var tuning: Tuning = .tenor
    
    var displayChord: String {
        return detectedChord
    }
    
    private let engine = ChordEngine()
    private var audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var lingerTimer: Timer?
    
    init() {
        self.tuning = audioManager.tuning
        setupSubscriptions()
    }
    
    func start() {
        engine.start()
    }
    
    func stop() {
        engine.stop()
    }
    
    private func setupSubscriptions() {
        // Sync tuning changes from UI back to AudioManager
        $tuning
            .dropFirst()
            .sink { [weak self] newTuning in
                self?.audioManager.tuning = newTuning
            }
            .store(in: &cancellables)
            
        // Sync tuning changes from AudioManager back to UI
        audioManager.$tuning
            .sink { [weak self] newTuning in
                if self?.tuning != newTuning {
                    self?.tuning = newTuning
                }
            }
            .store(in: &cancellables)
            
        // Observe engine results
        engine.$detectedChord
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chord in
                guard let self = self else { return }
                self.detectedChord = chord
                
                if chord != "--" && chord != "?" {
                    // Update History
                    if self.chordHistory.first != chord {
                        self.chordHistory.insert(chord, at: 0)
                        if self.chordHistory.count > 4 { self.chordHistory.removeLast() }
                    }
                    
                    // Make it STICK for the UI glow
                    self.stickyDetectedChord = chord
                    self.lingerTimer?.invalidate()
                    self.lingerTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                        DispatchQueue.main.async {
                            withAnimation(.easeOut(duration: 0.4)) {
                                self.stickyDetectedChord = "--"
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
            
        engine.$confidence
            .receive(on: DispatchQueue.main)
            .assign(to: \.confidence, on: self)
            .store(in: &cancellables)
            
        engine.$chromaVector
            .receive(on: DispatchQueue.main)
            .assign(to: \.chromaVector, on: self)
            .store(in: &cancellables)
    }
}
