import SwiftUI
import Combine
import AudioToolbox

import AVFoundation

class MetronomeEngine: ObservableObject {
    static let shared = MetronomeEngine()
    
    @Published var bpm: Double = 100 {
        didSet {
            // Update scheduling if it's currently running
            if isPlaying {
                restart()
            }
        }
    }
    @Published var isPlaying = false
    @Published var flash = false
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    
    // High-tick and Low-tick buffers
    private var highTickBuffer: AVAudioPCMBuffer?
    private var lowTickBuffer: AVAudioPCMBuffer?
    
    private var beatCount = 0
    private var sessionID = UUID()
    
    init() {
        setupEngine()
        generateClickSounds()
    }
    
    func forcePlaybackSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    private func setupEngine() {
        engine.attach(player)
        let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Metronome Engine failed to start: \(error)")
        }
    }

    // Generate synth clicks dynamically so we don't need external WAV files
    private func generateClickSounds() {
        let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        // 0.05 seconds of click
        let frameCount = AVAudioFrameCount(sampleRate * 0.05)
        
        highTickBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        lowTickBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        
        highTickBuffer?.frameLength = frameCount
        lowTickBuffer?.frameLength = frameCount
        
        guard let highData = highTickBuffer?.floatChannelData?[0],
              let lowData = lowTickBuffer?.floatChannelData?[0] else { return }
        
        // High click = 2000 Hz, Low click = 1000 Hz
        for i in 0..<Int(frameCount) {
            let time = Float(i) / Float(sampleRate)
            // Exponential decay envelope
            let envelope = exp(-time * 100.0) 
            
            // Generate sine waves with decay
            highData[i] = sin(2.0 * Float.pi * 2000.0 * time) * envelope
            lowData[i] = sin(2.0 * Float.pi * 1000.0 * time) * envelope
        }
    }
    
    func toggle() {
        if isPlaying { stop() } else { start() }
    }
    
    func start() {
        guard !isPlaying else { return }
        forcePlaybackSession()
        
        isPlaying = true
        beatCount = 0
        sessionID = UUID()
        
        player.play()
        scheduleNextBeats(from: AVAudioTime(hostTime: mach_absolute_time()), for: sessionID)
    }
    
    func stop() {
        isPlaying = false
        player.stop()
    }
    
    func restart() {
        let wasPlaying = isPlaying
        stop()
        if wasPlaying { start() }
    }
    
    private func scheduleNextBeats(from time: AVAudioTime, for id: UUID) {
        guard isPlaying, sessionID == id else { return }
        
        let interval = 60.0 / bpm
        let framesPerBeat = AVAudioFramePosition(interval * engine.mainMixerNode.outputFormat(forBus: 0).sampleRate)
        
        // We schedule 4 beats at a time ahead of the clock.
        var scheduleTime = time

        for _ in 0..<4 {
            let buffer = (beatCount % 4 == 0) ? highTickBuffer : lowTickBuffer
            
            if let buf = buffer {
                player.scheduleBuffer(buf, at: scheduleTime, options: []) { [weak self] in
                    // This block executes when the buffer finishes playing in real-time
                    DispatchQueue.main.async {
                        guard self?.sessionID == id else { return }
                        self?.flash = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            guard self?.sessionID == id else { return }
                            self?.flash = false
                        }
                    }
                }
            }
            
            beatCount += 1
            let nextSampleTime = scheduleTime.sampleTime + framesPerBeat
            scheduleTime = AVAudioTime(sampleTime: nextSampleTime, atRate: scheduleTime.sampleRate)
        }
        
        // Recursively schedule the NEXT 4 beats exactly when this batch is supposed to run out.
        // We wrap it in a block so we only continue if still playing.
        let dispatchTime = DispatchTime.now() + (interval * 2.5) // Halfway through the batch
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: dispatchTime) { [weak self] in
            guard let self = self, self.isPlaying, self.sessionID == id else { return }
            self.scheduleNextBeats(from: scheduleTime, for: id)
        }
    }
    

}

struct MetronomeView: View {
    @StateObject private var engine = MetronomeEngine.shared
    
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
                        .fill(engine.isPlaying ? (engine.flash ? Color.blue : Color.blue.opacity(0.6)) : Color.gray)
                        .frame(width: 180, height: 180)
                        .scaleEffect(engine.flash ? 1.05 : 1.0)
                        .animation(.spring(response: 0.1, dampingFraction: 0.5), value: engine.flash)
                        .shadow(color: engine.isPlaying ? Color.blue.opacity(0.5) : Color.clear, radius: 20)
                    
                    Text("\(Int(engine.bpm))")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("BPM")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: 35)
                }
                
                // Controls
                VStack(spacing: 30) {
                    Slider(value: $engine.bpm, in: 40...200, step: 1)
                        .accentColor(.blue)
                        .padding(.horizontal, 40)
                    
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
