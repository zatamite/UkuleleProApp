import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }
    
    private init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
    }
    
    // Stub for now to prevent build errors in other files
    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        // Haptics disabled due to interference with microphone sensors
    }
}
