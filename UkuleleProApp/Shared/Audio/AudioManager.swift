import Foundation
import AudioKit
import AudioKitEX
import SoundpipeAudioKit
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    let engine = AudioEngine()
    private let mixer = Mixer()
    
    private var tracker: PitchTap?
    private var fft: FFTTap?
    
    // Serial Chain Nodes to prevent Tap Collisions
    private let node1 = Mixer() // For PitchTap
    private let node2 = Mixer() // For FFTTap
    private let node3 = Mixer() // For Raw Buffer Tap
    
    // Circular buffer for the last ~1 second of audio
    private let bufferCapacity = 48000 // Increased to handle 48k sessions
    @Published var audioBuffer: [Float] = []
    
    @Published var tuning: Tuning = .baritone
    @Published var currentFrequency: Float = 0.0
    @Published var amplitude: Float = 0.0
    @Published var fftData: [Float] = Array(repeating: 0.0, count: 512)
    @Published var isRunning = false
    @Published var sampleRate: Double = 44100.0
    
    // Mode to disable chord analysis during tuning for performance and stability
    var isTuningOnly = false
    
    private let main = DispatchQueue.main
    
    private init() {
        #if os(iOS)
        setupSession()
        #endif
        setupEngine()
    }
    
    private func setupSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try session.setActive(true)
            
            // Sync AudioKit to Hardware Rate
            Settings.sampleRate = session.sampleRate
            self.sampleRate = session.sampleRate
            print("AudioManager: Hardware Sample Rate recognized as: \(session.sampleRate)")
            LogManager.shared.log("Hardware Sample Rate: \(session.sampleRate) Hz", source: "AudioManager", level: .info)
        } catch {
            print("AudioManager: AVAudioSession error: \(error)")
        }
    }
    
    private func setupEngine() {
        guard let input = engine.input else { 
            print("AudioManager: No input available")
            return 
        }
        
        // Serial Chain: Input -> Node1 -> Node2 -> Node3 -> Mixer -> Output
        // This gives us 3 distinct places to attach taps without collision
        
        // Ensure intermediate nodes pass audio through
        node1.volume = 1.0
        node2.volume = 1.0
        node3.volume = 1.0
        
        // Build the chain
        node1.addInput(input)
        node2.addInput(node1)
        node3.addInput(node2)
        mixer.addInput(node3)
        
        // Silence the final output to prevent feedback
        mixer.volume = 0 
        
        // Setting the output tells AudioKit to traverse and attach all connected nodes
        engine.output = mixer
    }
    
    func start() {
        guard !isRunning else { return }
        
        do {
            // 1. Reset Session Category (Crucial if Metronome changed it)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try session.setActive(true)
            
            // 2. Start Engine
            try engine.start()
            
            // 3. Hardware Stability Delay: Wait 0.5s before tapping
            // This allows the iPhone 16 Pro hardware to stabilize the audio unit.
            main.asyncAfter(deadline: .now() + 0.5) {
                self.installTaps()
            }
            
            main.async {
                self.isRunning = true
            }
            print("AudioManager: Engine started. Waiting for hardware handshake...")
            LogManager.shared.log("Engine Starting...", source: "AudioManager", level: .info)
        } catch {
            print("AudioManager: Could not start engine: \(error)")
             LogManager.shared.log("Startup Failed: \(error.localizedDescription)", source: "AudioManager", level: .error)
        }
    }
    
    private func installTaps() {
        // Remove old taps safely
        tracker?.stop()
        node1.avAudioNode.removeTap(onBus: 0)
        
        fft?.stop()
        node2.avAudioNode.removeTap(onBus: 0)
        
        node3.avAudioNode.removeTap(onBus: 0)
        
        // 1. Pitch Tap on Node 1 (Always needed)
        tracker = PitchTap(node1) { pitch, amp in
            DispatchQueue.main.async {
                self.currentFrequency = pitch[0]
                self.amplitude = amp[0]
            }
        }
        tracker?.start()
        
        // 2. Heavy processing on Node 2 & 3 (Only if not tuning)
        if !isTuningOnly {
            print("AudioManager: Chord analysis enabled.")
            LogManager.shared.log("Chord Sensors Enabled (Heavy Mode)", source: "AudioManager", level: .debug)
            
            // FFT Tap on Node 2
            fft = FFTTap(node2) { fftData in
                DispatchQueue.main.async {
                    self.fftData = fftData
                }
            }
            fft?.start()
            
            // Raw Buffer Tap on Node 3
            let format = node3.avAudioNode.inputFormat(forBus: 0)
            node3.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
                guard let channelData = buffer.floatChannelData?[0] else { return }
                let frameLength = Int(buffer.frameLength)
                let data = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
                
                DispatchQueue.main.async {
                    self.audioBuffer.append(contentsOf: data)
                    if self.audioBuffer.count > self.bufferCapacity {
                        self.audioBuffer.removeFirst(self.audioBuffer.count - self.bufferCapacity)
                    }
                }
            }
        } else {
            print("AudioManager: Tuning-only mode. Chord sensors disabled for performance.")
            LogManager.shared.log("Tuning Only Mode (Sensors Disabled)", source: "AudioManager", level: .info)
        }
        
        print("AudioManager: Taps installed and sensor loop active.")
        LogManager.shared.log("Hardware Handshake Complete. Taps Active.", source: "AudioManager", level: .info)
    }
    
    // MARK: - Strum Latch Support
    func getLastSamples(count: Int) -> [Float] {
        // Thread-safe copy of the buffer suffix
        // Note: access to audioBuffer is on main thread due to @Published
        guard audioBuffer.count >= count else { return audioBuffer }
        return Array(audioBuffer.suffix(count))
    }
    
    func configureMode(isTuningOnly: Bool) {
        // Only reconfigure if the mode actually changed
        guard self.isTuningOnly != isTuningOnly else { return }
        
        self.isTuningOnly = isTuningOnly
        print("AudioManager: Switching mode. Tuning Only: \(isTuningOnly)")
        LogManager.shared.log("Switching Mode -> TuningOnly: \(isTuningOnly)", source: "AudioManager", level: .info)
        
        // precise reconfiguration without stopping engine
        if isRunning {
            installTaps()
        }
    }
    
    func stop() {
        tracker?.stop()
        node1.avAudioNode.removeTap(onBus: 0)
        
        fft?.stop()
        node2.avAudioNode.removeTap(onBus: 0)
        
        node3.avAudioNode.removeTap(onBus: 0)
        
        engine.stop()
        
        main.async {
            self.isRunning = false
        }
        print("AudioManager: Engine stopped")
        LogManager.shared.log("Engine Stopped", source: "AudioManager", level: .warning)
    }
}
