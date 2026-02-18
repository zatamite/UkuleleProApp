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
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    AudioManager.shared.start()
                }
            }
        }
    }
}
