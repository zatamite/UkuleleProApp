import SwiftUI

struct SongDetailView: View {
    let song: Song
    @StateObject var chordViewModel = ChordDetectionViewModel()
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack {
                Text(song.title)
                    .font(.title2.bold())
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Live Feedback Bar
            HStack {
                Text("Detecting:")
                    .font(.caption.bold())
                Text(chordViewModel.displayChord)
                    .font(.title3.bold())
                    .foregroundColor(chordViewModel.isInLimbo ? .orange : .blue)
                
                if chordViewModel.isInLimbo {
                    Text("(Refining...)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Text(AudioManager.shared.tuning.displayName)
                    .font(.caption)
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            
            // Lyrics & Chords ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(song.lines) { line in
                            SongLineView(line: line, currentDetectedChord: chordViewModel.displayChord)
                                .id(line.id)
                        }
                    }
                    .padding()
                }
                .onAppear { self.scrollProxy = proxy }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SongLineView: View {
    let line: SongLine
    let currentDetectedChord: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                ForEach(0..<line.segments.count, id: \.self) { i in
                    switch line.segments[i] {
                    case .chord(let chord):
                        Text(chord)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(currentDetectedChord == chord ? .blue : .primary.opacity(0.6))
                            .padding(.horizontal, 2)
                            .background(currentDetectedChord == chord ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(4)
                    case .lyric(let text):
                        Text(text)
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }
}
