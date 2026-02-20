import Foundation
import AudioKit
import AudioKitEX
import SoundpipeAudioKit
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    let engine = AudioEngine()
    private var mic: AudioEngine.InputNode?
    private var silence: Fader?
    private var tracker: PitchTap?
    private var fft: FFTTap?
    
    // Circular buffer for the last ~1 second of audio (44100 samples)
    private let bufferCapacity = 44100
    @Published var audioBuffer: [Float] = []
    
    @Published var tuning: Tuning = .tenor
    @Published var currentFrequency: Float = 0.0
    @Published var amplitude: Float = 0.0
    @Published var fftData: [Float] = Array(repeating: 0.0, count: 512)
    @Published var isRunning = false
    
    private init() {
        setupEngine()
    }
    
    private func setupEngine() {
        guard let input = engine.input else { 
            print("AudioManager: No input available")
            return 
        }
        
        mic = input
        
        // Wrap input in a fader to silence it
        silence = Fader(input, gain: 0)
        engine.output = silence
        
        tracker = PitchTap(input) { pitch, amp in
            DispatchQueue.main.async {
                self.currentFrequency = pitch[0]
                self.amplitude = amp[0]
            }
        }
        
        fft = FFTTap(input) { fftData in
            DispatchQueue.main.async {
                self.fftData = fftData
            }
        }
        
        // Use a generic tap to collect raw audio for the refinement buffer
        input.avAudioNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, time in
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
    }
    
    func start() {
        do {
            try engine.start()
            tracker?.start()
            fft?.start()
            isRunning = true
            print("AudioManager: Engine started")
        } catch {
            print("AudioManager: Could not start engine: \(error)")
        }
    }
    
    func stop() {
        engine.stop()
        tracker?.stop()
        fft?.stop()
        mic?.avAudioNode.removeTap(onBus: 0)
        isRunning = false
        print("AudioManager: Engine stopped")
    }
}
