import Foundation

struct ChordShape: Codable, Identifiable {
    var id: String { "\(tuning.rawValue)_\(name)" }
    let name: String
    let tuning: Tuning
    let frets: [Int?]         // nil = muted X, 0 = open O, n = fret number
    let fingers: [Int?]       // finger numbers 1-4
    let barre: BarreShape?
    let startFret: Int        // for high-up shapes (shows fret number label)
    
    struct BarreShape: Codable {
        let fret: Int
        let fromString: Int
        let toString: Int
    }
}
