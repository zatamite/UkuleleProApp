import SwiftUI

struct SongListView: View {
    let songs = SongLibrary.shared.samples
    
    var body: some View {
        NavigationView {
            List(songs) { song in
                NavigationLink(destination: SongDetailView(song: song)) {
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Songbook")
        }
    }
}
