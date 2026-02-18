import SwiftUI

struct AnalogGaugeView: View {
    var cents: Double // -50 to +50
    var isNoteDetected: Bool
    
    var body: some View {
        ZStack {
            // Background Glow
            Circle()
                .fill(glowColor)
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .opacity(isNoteDetected ? 0.3 : 0.1)
                .animation(.easeInOut(duration: 0.5), value: cents)
            
            // Gauge Arc
            ArcShape()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                .frame(width: 250, height: 250)
            
            // Tick Marks
            ForEach(0..<11) { i in
                TickMark(index: i)
            }
            
            // Needle
            NeedleShape()
                .fill(needleColor)
                .frame(width: 4, height: 120)
                .offset(y: -60)
                .rotationEffect(.degrees(cents * 1.8)) // Map -50..50 to -90..90
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cents)
            
            // Center Cap
            Circle()
                .fill(needleColor)
                .frame(width: 12, height: 12)
        }
    }
    
    private var glowColor: Color {
        if !isNoteDetected { return .gray }
        let absCents = abs(cents)
        if absCents < 5 { return .green }
        if absCents < 20 { return .yellow }
        return .red
    }
    
    private var needleColor: Color {
        if !isNoteDetected { return .secondary }
        let absCents = abs(cents)
        return absCents < 5 ? .green : .primary
    }
}

struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: .degrees(180),
                    endAngle: .degrees(360),
                    clockwise: false)
        return path
    }
}

struct TickMark: View {
    var index: Int
    
    var body: some View {
        Rectangle()
            .fill(index == 5 ? Color.green : Color.secondary.opacity(0.5))
            .frame(width: index == 5 ? 3 : 1, height: index == 5 ? 20 : 10)
            .offset(y: -120)
            .rotationEffect(.degrees(Double(index - 5) * 18))
    }
}

struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 10))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 10),
                          control: CGPoint(x: rect.midX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct AnalogGaugeView_Previews: PreviewProvider {
    static var previews: some View {
        AnalogGaugeView(cents: 0, isNoteDetected: true)
            .preferredColorScheme(.dark)
    }
}
