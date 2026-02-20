import SwiftUI

struct ChordDiagramView: View {
    let shape: ChordShape
    
    var body: some View {
        VStack(spacing: 8) {
            Text(shape.name)
                .font(.headline)
            
            Canvas { context, size in
                let margin: CGFloat = 20
                let stringSpacing = (size.width - 2 * margin) / 3
                let fretSpacing = (size.height - 2 * margin) / 4
                
                // Draw Fret Lines
                for i in 0...4 {
                    let y = margin + CGFloat(i) * fretSpacing
                    var path = Path()
                    path.move(to: CGPoint(x: margin, y: y))
                    path.addLine(to: CGPoint(x: size.width - margin, y: y))
                    
                    if i == 0 && shape.startFret == 1 {
                        context.stroke(path, with: .color(.primary), lineWidth: 4)
                    } else {
                        context.stroke(path, with: .color(.secondary.opacity(0.5)), lineWidth: 1)
                    }
                }
                
                // Draw String Lines
                for i in 0...3 {
                    let x = margin + CGFloat(i) * stringSpacing
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: margin))
                    path.addLine(to: CGPoint(x: x, y: size.height - margin))
                    context.stroke(path, with: .color(.secondary.opacity(0.5)), lineWidth: 1)
                }
                
                // Draw Fret Positions (Dots)
                for (stringIndex, fret) in shape.frets.enumerated() {
                    let x = margin + CGFloat(stringIndex) * stringSpacing
                    
                    if let f = fret, f > 0 {
                        let relativeFret = CGFloat(f - shape.startFret + 1)
                        let y = margin + (relativeFret - 0.5) * fretSpacing
                        
                        let dotSize: CGFloat = 12
                        context.fill(Path(ellipseIn: CGRect(x: x - dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize)), with: .color(.primary))
                        
                        // Finger number (optional)
                        if let finger = shape.fingers[stringIndex] {
                            context.draw(Text("\(finger)").font(.system(size: 8, weight: .bold)).foregroundColor(.white), at: CGPoint(x: x, y: y))
                        }
                    } else if fret == 0 {
                        // Open string circle
                        let r: CGFloat = 4
                        context.stroke(Path(ellipseIn: CGRect(x: x - r, y: margin - r * 2.5, width: r * 2, height: r * 2)), with: .color(.primary), lineWidth: 1)
                    } else {
                        // Muted string X
                        let r: CGFloat = 4
                        var path = Path()
                        path.move(to: CGPoint(x: x - r, y: margin - r * 2.5))
                        path.addLine(to: CGPoint(x: x + r, y: margin - r * 0.5))
                        path.move(to: CGPoint(x: x + r, y: margin - r * 2.5))
                        path.addLine(to: CGPoint(x: x - r, y: margin - r * 0.5))
                        context.stroke(path, with: .color(.primary), lineWidth: 1)
                    }
                }
                
                // Start Fret Label
                if shape.startFret > 1 {
                    context.draw(Text("\(shape.startFret)").font(.caption), at: CGPoint(x: 5, y: margin + fretSpacing / 2))
                }
            }
            .frame(width: 120, height: 160)
        }
    }
}

struct ChordDiagramView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ChordDiagramView(shape: ChordShape(
                name: "C",
                tuning: .tenor,
                frets: [0, 0, 0, 3],
                fingers: [nil, nil, nil, 3],
                barre: nil,
                startFret: 1
            ))
            
            ChordDiagramView(shape: ChordShape(
                name: "G",
                tuning: .baritone,
                frets: [0, 0, 0, 3],
                fingers: [nil, nil, nil, 3],
                barre: nil,
                startFret: 1
            ))
        }
        .padding()
    }
}
