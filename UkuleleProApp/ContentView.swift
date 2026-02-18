import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
