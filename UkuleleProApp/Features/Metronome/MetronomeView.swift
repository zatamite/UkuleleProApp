import SwiftUI
import Combine
import AudioToolbox

import AVFoundation

// Simple sound engine to ensure consistency
class MetronomeEngine: ObservableObject {
    static let shared = MetronomeEngine()
    
    @Published var bpm: Double = 100
    @Published var isPlaying = false
    
    private var beatTimer: Timer?
    private var beatCount = 0
    
    init() {
        forcePlaybackSession()
    }
    
    func forcePlaybackSession() {
        do {
            // Ensure we can play sound even in silent mode
            // Stop any other engines first if possible
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    func toggle() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        guard !isPlaying else { return }
        
        // Re-activate session just in case
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("Audio Session Error: \(error)") }
        
        isPlaying = true
        scheduleNext()
    }
    
    func stop() {
        isPlaying = false
        beatTimer?.invalidate()
        beatTimer = nil
        beatCount = 0
    }
    
    func restart() {
        stop()
        start()
    }
    
    private func scheduleNext() {
        let interval = 60.0 / bpm
        tick()
        beatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        beatCount += 1
        
        // Audio Feedback
        // 1057 (Tink) and 1306 (Tock) are good standard sounds.
        // We use AudioServicesPlayAlertSound to try and bypass silent switch if possible,
        // but .playback category is the real key.
        let soundID: SystemSoundID = (beatCount % 4 == 1) ? 1057 : 1103
        AudioServicesPlaySystemSound(soundID)
        
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: beatCount % 4 == 1 ? .heavy : .light)
        generator.impactOccurred()
    }
}

struct MetronomeView: View {
    @StateObject private var engine = MetronomeEngine.shared
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Metronome")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)
                
                Spacer()
                
                // Visual Pulse
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(engine.isPlaying ? (pulse ? Color.blue : Color.blue.opacity(0.6)) : Color.gray)
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulse ? 1.05 : 1.0)
                        .animation(.spring(response: 0.1, dampingFraction: 0.5), value: pulse)
                        .shadow(color: engine.isPlaying ? Color.blue.opacity(0.5) : Color.clear, radius: 20)
                    
                    Text("\(Int(engine.bpm))")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("BPM")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: 35)
                }
                .onReceive(Timer.publish(every: 60.0 / engine.bpm, on: .main, in: .common).autoconnect()) { _ in
                    if engine.isPlaying {
                        pulse = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            pulse = false
                        }
                    }
                }
                
                // Controls
                VStack(spacing: 30) {
                    Slider(value: $engine.bpm, in: 40...200, step: 1)
                        .accentColor(.blue)
                        .padding(.horizontal, 40)
                        .onChange(of: engine.bpm) { 
                            if engine.isPlaying { engine.restart() }
                        }
                    
                    HStack(spacing: 40) {
                        Button(action: { 
                            if engine.bpm > 40 { engine.bpm -= 1 }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                engine.toggle()
                            }
                        }) {
                            Image(systemName: engine.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(engine.isPlaying ? .red : .green)
                        }
                        
                        Button(action: { 
                            if engine.bpm < 200 { engine.bpm += 1 }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Stop other audio engines to release microphone
            AudioManager.shared.stop()
            
            // Force Playback session
            MetronomeEngine.shared.forcePlaybackSession()
        }
        .onDisappear {
            // Stop metronome to be polite
            MetronomeEngine.shared.stop()
            
            // Re-enable microphone for other tabs
            AudioManager.shared.start()
        }
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView()
    }
}
