import SwiftUI
import AVFoundation

@main
struct UkuleleProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestMicrophonePermission()
                }
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Microphone permission granted")
                DispatchQueue.main.async {
                    AudioManager.shared.start()
                }
            } else {
                print("Microphone permission denied")
            }
        }
    }
}
