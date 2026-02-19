import SwiftUI

struct SongListView: View {
    @ObservedObject var settings = SettingsManager.shared
    let songs = SongLibrary.shared.samples
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(settings.isDarkMode ? .black : .white)
                    .ignoresSafeArea()
                
                if settings.isDarkMode {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color(white: 0.08)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
                
                List(filteredSongs) { song in
                    NavigationLink(destination: SongDetailView(song: song)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.title)
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(settings.isDarkMode ? .white : .black)
                            Text(song.artist)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.white.opacity(settings.isDarkMode ? 0.05 : 0.5))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
            .navigationTitle("Songbook")
            .toolbarColorScheme(settings.isDarkMode ? .dark : .light, for: .navigationBar)
        }
    }
    
    @State private var searchText = ""
    var filteredSongs: [Song] {
        if searchText.isEmpty { return songs }
        return songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.artist.localizedCaseInsensitiveContains(searchText) }
    }
}
