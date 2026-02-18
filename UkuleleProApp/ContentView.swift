import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                TunerView()
                    .tabItem {
                        Label("Tuner", systemImage: "tuningfork")
                    }
                
                ChordDetectionView()
                    .tabItem {
                        Label("Detect", systemImage: "waveform.path")
                    }
                
            }
            
            // Global Debug Overlay
            DebugConsoleView()
                .padding(.bottom, 50) // Adjust for tab bar
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
