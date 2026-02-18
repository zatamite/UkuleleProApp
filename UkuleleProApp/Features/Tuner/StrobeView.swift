import SwiftUI
import Combine

struct StrobeView: View {
    var cents: Double
    var isNoteDetected: Bool
    
    // Sensitivity: How fast it spins per cent of deviation
    // Higher = faster spin for small errors (more sensitive)
    private let sensitivity: Double = 2.0
    
    @State private var rotation: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Disc
                Circle()
                    .fill(
                        RadialGradient(gradient: Gradient(colors: [Color.black, Color(white: 0.2)]),
                                     center: .center,
                                     startRadius: 0,
                                     endRadius: geometry.size.width / 2)
                    )
                    .overlay(
                        Circle().stroke(Color(white: 0.3), lineWidth: 4)
                    )
                
                // Strobe Pattern (Checkerboard / Radial lines)
                if isNoteDetected {
                    StrobePattern()
                        .fill(isInTune ? Color.green : Color.white)
                        .rotationEffect(.degrees(rotation))
                        .mask(Circle())
                } else {
                    // Idle State
                    StrobePattern()
                        .fill(Color.gray.opacity(0.3))
                        .rotationEffect(.degrees(0)) // Stationary when no note
                        .mask(Circle())
                }
                
                // Center Hub
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.4), Color(white: 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                    .shadow(radius: 5)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            guard isNoteDetected else { return }
            
            // Strobe Physics:
            // Deviation > 0 (Sharp) -> Clockwise
            // Deviation < 0 (Flat) -> Counter-Clockwise
            // Speed proportional to absolute deviation
            
            // Normalize spin: 1 cent off = slow drift
            let spinSpeed = cents * sensitivity * 0.05
            rotation += spinSpeed
        }
    }
    
    private var isInTune: Bool {
        return abs(cents) < 5.0
    }
}

struct StrobePattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let segments = 12 // Number of "teeth" on the strobe wheel
        let angleStep = 360.0 / Double(segments)
        
        for i in 0..<segments {
            let startAngle = Angle(degrees: Double(i) * angleStep)
            let endAngle = Angle(degrees: (Double(i) * angleStep) + (angleStep / 2))
            
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.closeSubpath()
        }
        
        return path
    }
}

struct StrobeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StrobeView(cents: 10, isNoteDetected: true)
                .frame(width: 200, height: 200)
            StrobeView(cents: -20, isNoteDetected: true)
                .frame(width: 200, height: 200)
            StrobeView(cents: 0, isNoteDetected: false)
                .frame(width: 200, height: 200)
        }
        .padding()
        .background(Color.black)
    }
}
