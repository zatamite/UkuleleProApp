import SwiftUI

struct ChordDiagramView: View {
    let shape: ChordShape
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            Text(shape.name)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(settings.isDarkMode ? .white : .black)
            
            Canvas { context, size in
                let margin: CGFloat = 12
                let innerWidth = size.width - 2 * margin
                let innerHeight = size.height - 2 * margin
                let stringSpacing = innerWidth / 3
                let fretSpacing = innerHeight / 4
                
                let textColor = settings.isDarkMode ? Color.white : Color.black
                let gridColor = settings.isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.2)
                
                // Draw Fret Lines
                for i in 0...4 {
                    let y = margin + CGFloat(i) * fretSpacing
                    var path = Path()
                    path.move(to: CGPoint(x: margin, y: y))
                    path.addLine(to: CGPoint(x: size.width - margin, y: y))
                    
                    if i == 0 && shape.startFret == 1 {
                        context.stroke(path, with: .color(textColor), lineWidth: 3)
                    } else {
                        context.stroke(path, with: .color(gridColor), lineWidth: 1)
                    }
                }
                
                // Draw String Lines
                for i in 0...3 {
                    let x = margin + CGFloat(i) * stringSpacing
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: margin))
                    path.addLine(to: CGPoint(x: x, y: size.height - margin))
                    context.stroke(path, with: .color(gridColor), lineWidth: 1)
                }
                
                // Draw Dots
                for (stringIndex, fret) in shape.frets.enumerated() {
                    let x = margin + CGFloat(stringIndex) * stringSpacing
                    
                    if let f = fret, f > 0 {
                        let relativeFret = CGFloat(f - shape.startFret + 1)
                        let y = margin + (relativeFret - 0.5) * fretSpacing
                        
                        let dotSize: CGFloat = 10
                        context.fill(Path(ellipseIn: CGRect(x: x - dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize)), with: .color(.blue))
                        
                        // Finger number
                        if let finger = shape.fingers[stringIndex] {
                            context.draw(Text("\(finger)").font(.system(size: 6, weight: .bold)).foregroundColor(.white), at: CGPoint(x: x, y: y))
                        }
                    } else if fret == 0 {
                        // Open circle
                        let r: CGFloat = 3
                        context.stroke(Path(ellipseIn: CGRect(x: x - r, y: margin - r * 2, width: r * 2, height: r * 2)), with: .color(.blue), lineWidth: 1.5)
                    } else {
                        // Muted X
                        let r: CGFloat = 3
                        var path = Path()
                        path.move(to: CGPoint(x: x - r, y: margin - r * 2))
                        path.addLine(to: CGPoint(x: x + r, y: margin - r * 0.5))
                        path.move(to: CGPoint(x: x + r, y: margin - r * 2))
                        path.addLine(to: CGPoint(x: x - r, y: margin - r * 0.5))
                        context.stroke(path, with: .color(.secondary), lineWidth: 1)
                    }
                }
                
                // Start Fret Label
                if shape.startFret > 1 {
                    context.draw(Text("\(shape.startFret)f").font(.system(size: 8, weight: .bold)), at: CGPoint(x: 5, y: margin + fretSpacing / 2))
                }
            }
            .frame(width: 80, height: 100)
        }
        .padding(8)
        .background(Color.white.opacity(settings.isDarkMode ? 0.05 : 0.03))
        .cornerRadius(12)
    }
}
