import SwiftUI

struct ChordDetectionView: View {
    @StateObject var viewModel = ChordDetectionViewModel()
    
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Chord Detection")
                .font(.title2.bold())
            
            Picker("Tuning", selection: $viewModel.tuning) {
                ForEach(Tuning.allCases, id: \.self) { tuning in
                    Text(tuning.displayName).tag(tuning)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Spacer()
            
            // Main Chord Display
            VStack {
                Text(viewModel.displayChord)
                    .font(.system(size: 100, weight: .black, design: .rounded))
                    .foregroundColor(viewModel.isInLimbo ? .orange : .primary)
                
                if viewModel.isInLimbo {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Refining...")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary.opacity(0.1))
            )
            
            // Confidence Bar
            VStack(alignment: .leading) {
                Text("Confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                        
                        Capsule()
                            .fill(viewModel.confidence > 0.7 ? Color.green : Color.yellow)
                            .frame(width: geometry.size.width * CGFloat(viewModel.confidence))
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 40)
            
            // Chroma Visualizer
            VStack(alignment: .leading) {
                Text("Chroma Signature")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<12) { i in
                        VStack {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(width: 20, height: 100)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.blue)
                                    .frame(width: 20, height: CGFloat(viewModel.chromaVector[i] * 100))
                            }
                            Text(noteNames[i])
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct ChordDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ChordDetectionView()
    }
}
