import SwiftUI

struct TunerView: View {
    @StateObject var viewModel = TunerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Picker("Tuning", selection: $viewModel.tuning) {
                ForEach(Tuning.allCases, id: \.self) { tuning in
                    Text(tuning.displayName).tag(tuning)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            VStack {
                Text(viewModel.currentNote)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                
                Text(String(format: "%.1f Hz", viewModel.currentPitch))
                    .foregroundColor(.secondary)
            }
            
            // Tuner indicator
            GeometryReader { geometry in
                ZStack {
                    // Background scale
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
                    
                    // Center mark
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 2, height: 20)
                    
                    // Needle
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(abs(viewModel.centsDeviation) < 5 ? .green : .red)
                        .offset(x: viewModel.currentPitch > 0 ? CGFloat(viewModel.centsDeviation / 50.0) * (geometry.size.width / 2) : 0)
                        .animation(.spring(), value: viewModel.centsDeviation)
                }
            }
            .frame(height: 20)
            .padding(.horizontal, 40)
            
            HStack {
                VStack {
                    Text("FLAT")
                        .font(.caption)
                    Image(systemName: "arrow.left")
                }
                Spacer()
                VStack {
                    Text("SHARP")
                        .font(.caption)
                    Image(systemName: "arrow.right")
                }
            }
            .padding(.horizontal, 60)
            .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.toggleTuner()
            }) {
                Text(viewModel.isRunning ? "Stop Tuner" : "Start Tuner")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isRunning ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}
