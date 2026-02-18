import SwiftUI

struct ChordDetectionView: View {
    @StateObject var viewModel = ChordDetectionViewModel()
    
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // Chord color reacts to confidence
    var chordColor: Color {
        if viewModel.detectedChord == "--" || viewModel.detectedChord == "?" {
            return .secondary
        }
        return viewModel.confidence > 0.75 ? .green : .blue
    }
    
    var body: some View {
        ZStack {
            // Match Tuner's dark background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.08)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Spacer()
                
                // Main Chord Display
                ZStack {
                    // Pulse ring
                    Circle()
                        .stroke(chordColor.opacity(0.15), lineWidth: 20)
                        .frame(width: 220, height: 220)
                    Circle()
                        .stroke(chordColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    Text(viewModel.displayChord)
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                        .foregroundColor(chordColor)
                        .shadow(color: chordColor.opacity(0.6), radius: 12)
                        .frame(width: 180)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.detectedChord)
                }
                
                // Confidence Bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%%", viewModel.confidence * 100))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(chordColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, chordColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(viewModel.confidence))
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.confidence)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 40)
                
                // Chroma Visualizer
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chroma Signature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    HStack(alignment: .bottom, spacing: 3) {
                        ForEach(0..<12) { i in
                            VStack(spacing: 3) {
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.06))
                                        .frame(width: 22, height: 80)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.7), .cyan],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 22, height: CGFloat(viewModel.chromaVector[i] * 80))
                                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: viewModel.chromaVector[i])
                                }
                                Text(noteNames[i])
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .onAppear {
            AudioManager.shared.start()
            AudioManager.shared.configureMode(isTuningOnly: false)
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

struct ChordDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ChordDetectionView()
    }
}
