import SwiftUI

struct TunerView: View {
    @StateObject var viewModel = TunerViewModel()
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Text("BARITONE UKULELE")
                        .font(.system(size: 18, weight: .black))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    
                    HStack {
                        Spacer()
                        Text(viewModel.isRunning ? "LIVE" : "PAUSED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(viewModel.isRunning ? .green : .secondary)
                        Spacer()
                    }
                    
                    // String Reference
                    HStack(spacing: 20) {
                        ForEach(viewModel.tuning.stringNotes, id: \.self) { string in
                            Text(string)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(viewModel.currentNote.starts(with: string.prefix(1)) ? .green : .secondary)
                                .padding(8)
                                .background(Circle().stroke(viewModel.currentNote.starts(with: string.prefix(1)) ? Color.green : Color.secondary.opacity(0.3)))
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
                
                // Mode Toggle
                Picker("Mode", selection: $viewModel.isStrobeMode) {
                    Text("Needle").tag(false)
                    Text("Strobe").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                
                Spacer()
                
                // Main Gauge Area
                if viewModel.isStrobeMode {
                    StrobeView(cents: viewModel.centsDeviation,
                              isNoteDetected: viewModel.currentNote != "--")
                        .frame(height: 300)
                } else {
                    AnalogGaugeView(cents: viewModel.centsDeviation,
                                   isNoteDetected: viewModel.currentNote != "--")
                        .scaleEffect(1.2)
                }
                
                // Note Indicator
                VStack(spacing: 5) {
                    Text(viewModel.currentNote)
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .scaleEffect(abs(viewModel.centsDeviation) < 5 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: viewModel.currentNote)
                    
                    HStack(spacing: 15) {
                        Text(String(format: "%.1f Hz", viewModel.currentPitch))
                        Text("|")
                        Text(String(format: "%+.0f cents", viewModel.centsDeviation))
                    }
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Control Button
                Button(action: {
                    withAnimation {
                        viewModel.toggleTuner()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRunning ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(viewModel.isRunning ? Color.red : Color.blue)
                            .frame(width: 64, height: 64)
                            .shadow(color: (viewModel.isRunning ? Color.red : Color.blue).opacity(0.5), radius: 10)
                        
                        Image(systemName: viewModel.isRunning ? "stop.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.start()
            AudioManager.shared.configureMode(isTuningOnly: true)
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}
