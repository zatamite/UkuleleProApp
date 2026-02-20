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
            
            SongListView()
                .tabItem {
                    Label("Songbook", systemImage: "music.note.list")
                }
            
            Text("Chord Dictionary (Future)")
                .tabItem {
                    Label("Library", systemImage: "book")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
