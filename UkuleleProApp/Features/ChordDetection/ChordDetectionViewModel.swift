import Foundation
import SwiftUI
import Combine

class ChordDetectionViewModel: ObservableObject {
    @Published var detectedChord: String = "--"
    @Published var stickyDetectedChord: String = "--"
    @Published var confidence: Float = 0.0
    @Published var chordHistory: [String] = []
    @Published var chromaVector: [Float] = Array(repeating: 0.0, count: 12)
    @Published var isShowingTuningSheet = false
    
    var tuning: Tuning {
        get { audioManager.tuning }
        set { audioManager.tuning = newValue }
    }
    
    var displayChord: String {
        return detectedChord
    }
    
    private let engine = ChordEngine()
    private var audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var lingerTimer: Timer?
    
    init() {
        setupSubscriptions()
    }
    
    func start() {
        engine.start()
    }
    
    func stop() {
        engine.stop()
    }
    
    private func setupSubscriptions() {
        // Forward tuning changes to the View
        audioManager.$tuning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
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
