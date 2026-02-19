import Foundation

struct ChordShape: Codable, Identifiable {
    var id: String { "\(tuning.rawValue)_\(name)" }
    let name: String
    let tuning: Tuning
    let frets: [Int?]         // nil = muted X, 0 = open O, n = fret number
    let fingers: [Int?]       // finger numbers 1-4
    let startFret: Int        // for high-up shapes (shows fret number label)
    
    // Quick constructor for common shapes
    static func create(_ name: String, _ tuning: Tuning, _ frets: [Int?], fingers: [Int?] = [nil, nil, nil, nil], start: Int = 1) -> ChordShape {
        return ChordShape(name: name, tuning: tuning, frets: frets, fingers: fingers, startFret: start)
    }
}
