import SwiftUI
import AudioToolbox

struct SongDetailView: View {
    let song: Song
    @StateObject var chordViewModel = ChordDetectionViewModel()
    @ObservedObject var settings = SettingsManager.shared
    @State private var selectedChordShape: ChordShape? = nil
    
    var body: some View {
        ZStack {
            Color(settings.isDarkMode ? .black : .white)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Live Sensing Bar (Premium UI)
                HStack {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .opacity(chordViewModel.detectedChord != "--" ? 1.0 : 0.3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LISTENING")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.secondary)
                            Text(chordViewModel.detectedChord)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    Text(chordViewModel.tuning.displayName)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(settings.isDarkMode ? 0.05 : 0.02))
                .overlay(alignment: .bottom) {
                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.1))
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(song.lines) { line in
                            SongLineView(line: line, currentDetectedChord: chordViewModel.stickyDetectedChord) { chordName in
                                if let shape = ChordLibrary.shared.getShape(for: chordName, tuning: chordViewModel.tuning) {
                                    selectedChordShape = shape
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 100)
                }
            }
            
            // Popover Diagram logic remains here...
            if let shape = selectedChordShape {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { selectedChordShape = nil }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            Button(action: { selectedChordShape = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                            }
                        }
                        .padding(.top, 8)
                        
                        ChordDiagramView(shape: shape)
                            .scaleEffect(1.3)
                        
                        Text("TAP ANYWHERE TO CLOSE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 32).fill(settings.isDarkMode ? Color(white: 0.12) : Color.white))
                    .shadow(color: .black.opacity(0.3), radius: 30)
                    .frame(width: 280)
                }
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                .zIndex(100)
            }
        }
        .navigationTitle(song.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AudioManager.shared.start()
            AudioManager.shared.configureMode(isTuningOnly: false)
            chordViewModel.start()
        }
        .onDisappear {
            chordViewModel.stop()
        }
    }
}

struct SongLineView: View {
    let line: SongLine
    let currentDetectedChord: String
    let onChordTap: (String) -> Void
    
    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(0..<line.segments.count, id: \.self) { i in
                switch line.segments[i] {
                case .text(let text):
                    // Split long text segments into words so they can wrap individually
                    // We map to Identifiable or use indices to keep SwiftUI happy
                    let words = text.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
                    
                    ForEach(0..<words.count, id: \.self) { wIndex in
                        Text(words[wIndex])
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundColor(.primary)
                            .padding(.top, 24) // Offset for potential neighbor chords
                            .fixedSize()
                    }
                    
                case .chorded(let chord, let text):
                    VStack(alignment: .leading, spacing: 2) {
                        let isHighlighted = currentDetectedChord == chord
                        
                        Button(action: { onChordTap(chord) }) {
                            Text(chord)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(isHighlighted ? .white : .blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isHighlighted ? Color.green : Color.blue.opacity(0.05))
                                )
                                .shadow(color: isHighlighted ? .green.opacity(0.6) : .clear, radius: 4)
                        }
                        
                        Text(text) // The word under the chord
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundColor(.primary)
                            .fixedSize()
                    }
                }
            }
        }
    }
}

// A simple FlowLayout helper for wrapping words and chords
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }
    
    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, points: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var points: [CGPoint] = []
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + 8
                lineHeight = 0
            }
            
            points.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width
            totalWidth = max(totalWidth, currentX)
        }
        
        return (CGSize(width: totalWidth, height: currentY + lineHeight), points)
    }
}

extension Animation {
    static var pulse: Animation {
        Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
    }
}
