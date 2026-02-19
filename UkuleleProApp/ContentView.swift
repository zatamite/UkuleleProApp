import SwiftUI

struct ContentView: View {
    @State private var selection = 1 // Default to Analyzer for quick access
    
    var body: some View {
        TabView(selection: $selection) {
            TunerView()
                .tabItem {
                    Label("Tuner", systemImage: "tuningfork")
                }
                .tag(0)
            
            ChordDetectionView()
                .tabItem {
                    Label("Analyzer", systemImage: "waveform.path.ecg")
                }
                .tag(1)
            
            MetronomeView()
                .tabItem {
                    Label("Metronome", systemImage: "metronome")
                }
                .tag(2)
            
            SongListView()
                .tabItem {
                    Label("Songbook", systemImage: "music.note.list")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Customize the Tab Bar for a "Pro" Glass look
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor(Color.black.opacity(0.2))
            
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = UIColor.gray
            itemAppearance.selected.iconColor = UIColor.systemBlue
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .onChange(of: selection) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
