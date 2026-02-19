import Foundation

class ChordLibrary {
    static let shared = ChordLibrary()
    
    private let tenorShapes: [String: ChordShape] = [
        // C Family
        "C":      ChordShape.create("C",      .tenor, [0, 0, 0, 3], fingers: [nil, nil, nil, 3]),
        "Cm":     ChordShape.create("Cm",     .tenor, [0, 3, 3, 3], fingers: [nil, 1, 1, 1]), // Barre 3rd
        "C7":     ChordShape.create("C7",     .tenor, [0, 0, 0, 1], fingers: [nil, nil, nil, 1]),
        "Cmaj7":  ChordShape.create("Cmaj7",  .tenor, [0, 0, 0, 2], fingers: [nil, nil, nil, 2]),
        "Csus4":  ChordShape.create("Csus4",  .tenor, [0, 0, 1, 3], fingers: [nil, nil, 1, 3]),
        
        // D Family
        "D":      ChordShape.create("D",      .tenor, [2, 2, 2, 0], fingers: [1, 2, 3, nil]),
        "Dm":     ChordShape.create("Dm",     .tenor, [2, 2, 1, 0], fingers: [2, 3, 1, nil]),
        "D7":     ChordShape.create("D7",     .tenor, [2, 2, 2, 3], fingers: [1, 1, 1, 2]), // Barre
        "Dmaj7":  ChordShape.create("Dmaj7",  .tenor, [2, 1, 2, 0], fingers: [2, 1, 3, nil]),
        
        // E Family
        "E":      ChordShape.create("E",      .tenor, [4, 4, 4, 2], fingers: [2, 3, 4, 1]),
        "Em":     ChordShape.create("Em",     .tenor, [0, 4, 3, 2], fingers: [nil, 3, 2, 1]),
        "E7":     ChordShape.create("E7",     .tenor, [1, 2, 0, 2], fingers: [1, 2, nil, 3]),
        "Emaj7":  ChordShape.create("Emaj7",  .tenor, [1, 3, 0, 2], fingers: [1, 3, nil, 2]),
        "Em7":    ChordShape.create("Em7",    .tenor, [0, 2, 0, 2], fingers: [nil, 1, nil, 2]),

        // F Family
        "F":      ChordShape.create("F",      .tenor, [2, 0, 1, 0], fingers: [2, nil, 1, nil]),
        "Fm":     ChordShape.create("Fm",     .tenor, [1, 0, 1, 3], fingers: [1, nil, 2, 4]),
        "F7":     ChordShape.create("F7",     .tenor, [2, 3, 1, 0], fingers: [2, 3, 1, nil]),
        "Fmaj7":  ChordShape.create("Fmaj7",  .tenor, [2, 4, 1, 3], fingers: [2, 4, 1, 3]),
        "Fsus4":  ChordShape.create("Fsus4",  .tenor, [3, 0, 1, 1], fingers: [3, nil, 1, 1]),

        // G Family
        "G":      ChordShape.create("G",      .tenor, [0, 2, 3, 2], fingers: [nil, 1, 3, 2]),
        "Gm":     ChordShape.create("Gm",     .tenor, [0, 2, 3, 1], fingers: [nil, 2, 3, 1]),
        "G7":     ChordShape.create("G7",     .tenor, [0, 2, 1, 2], fingers: [nil, 2, 1, 3]),
        "Gmaj7":  ChordShape.create("Gmaj7",  .tenor, [0, 2, 2, 2], fingers: [nil, 1, 1, 1]),
        "Gsus4":  ChordShape.create("Gsus4",  .tenor, [0, 2, 3, 3], fingers: [nil, 1, 2, 3]),
        
        // A Family
        "A":      ChordShape.create("A",      .tenor, [2, 1, 0, 0], fingers: [2, 1, nil, nil]),
        "Am":     ChordShape.create("Am",     .tenor, [2, 0, 0, 0], fingers: [2, nil, nil, nil]),
        "A7":     ChordShape.create("A7",     .tenor, [0, 1, 0, 0], fingers: [nil, 1, nil, nil]),
        "Amaj7":  ChordShape.create("Amaj7",  .tenor, [1, 1, 0, 0], fingers: [1, 2, nil, nil]),
        "Am7":    ChordShape.create("Am7",    .tenor, [0, 0, 0, 0], fingers: [nil, nil, nil, nil]), // Open!
        "Asus4":  ChordShape.create("Asus4",  .tenor, [2, 2, 0, 0], fingers: [2, 3, nil, nil]),

        // B Family
        "B":      ChordShape.create("B",      .tenor, [4, 3, 2, 2], fingers: [3, 2, 1, 1]), // Barre 2nd
        "Bm":     ChordShape.create("Bm",     .tenor, [4, 2, 2, 2], fingers: [3, 1, 1, 1]), // Barre 2nd
        "B7":     ChordShape.create("B7",     .tenor, [2, 3, 2, 2], fingers: [1, 2, 1, 1]), // Barre 2nd
        "Bb":     ChordShape.create("Bb",     .tenor, [3, 2, 1, 1], fingers: [3, 2, 1, 1]), // Barre 1st
        
        // Sharps & Flats
        "C#":     ChordShape.create("C#",     .tenor, [1, 1, 1, 4], fingers: [1, 1, 1, 4]), // Barre 1
        "Db":     ChordShape.create("Db",     .tenor, [1, 1, 1, 4], fingers: [1, 1, 1, 4]),
        "C#m":    ChordShape.create("C#m",    .tenor, [1, 4, 4, 4], fingers: [1, 3, 3, 3]), // Barre
        "Dbm":    ChordShape.create("Dbm",    .tenor, [1, 4, 4, 4], fingers: [1, 3, 3, 3]),
        
        "D#":     ChordShape.create("D#",     .tenor, [0, 3, 3, 1], fingers: [nil, 2, 3, 1]),
        "Eb":     ChordShape.create("Eb",     .tenor, [0, 3, 3, 1], fingers: [nil, 2, 3, 1]),
        "D#m":    ChordShape.create("D#m",    .tenor, [3, 3, 2, 1], fingers: [2, 3, 1, nil]),
        "Ebm":    ChordShape.create("Ebm",    .tenor, [3, 3, 2, 1], fingers: [2, 3, 1, nil]),
        
        "F#":     ChordShape.create("F#",     .tenor, [3, 1, 2, 1], fingers: [3, 1, 2, 1]),
        "Gb":     ChordShape.create("Gb",     .tenor, [3, 1, 2, 1], fingers: [3, 1, 2, 1]),
        "F#m":    ChordShape.create("F#m",    .tenor, [2, 1, 2, 0], fingers: [2, 1, 3, nil]),
        "Gbm":    ChordShape.create("Gbm",    .tenor, [2, 1, 2, 0], fingers: [2, 1, 3, nil]),
        
        "G#":     ChordShape.create("G#",     .tenor, [5, 3, 4, 3], fingers: [3, 1, 2, 1]),
        "Ab":     ChordShape.create("Ab",     .tenor, [5, 3, 4, 3], fingers: [3, 1, 2, 1]),
        "G#m":    ChordShape.create("G#m",    .tenor, [4, 3, 4, 2], fingers: [3, 2, 4, 1]),
        "Abm":    ChordShape.create("Abm",    .tenor, [4, 3, 4, 2], fingers: [3, 2, 4, 1]),
        
        "A#":     ChordShape.create("A#",     .tenor, [3, 2, 1, 1], fingers: [3, 2, 1, 1]),
        // "Bb" is already in B Family
        "A#m":    ChordShape.create("A#m",    .tenor, [3, 1, 1, 1], fingers: [3, 1, 1, 1]),
        "Bbm":    ChordShape.create("Bbm",    .tenor, [3, 1, 1, 1], fingers: [3, 1, 1, 1]),
    ]
    
    private let baritoneShapes: [String: ChordShape] = [
        // Baritone (D G B E) - Basic Library
        "C":      ChordShape.create("C",      .baritone, [2, 0, 1, 0], fingers: [2, nil, 1, nil]),
        "Cm":     ChordShape.create("Cm",     .baritone, [1, 0, 1, 3], fingers: [1, nil, 2, 4]),
        
        "D":      ChordShape.create("D",      .baritone, [0, 2, 3, 2], fingers: [nil, 1, 3, 2]),
        "Dm":     ChordShape.create("Dm",     .baritone, [0, 2, 3, 1], fingers: [nil, 2, 3, 1]),
        
        "E":      ChordShape.create("E",      .baritone, [2, 1, 0, 0], fingers: [2, 1, nil, nil]),
        "Em":     ChordShape.create("Em",     .baritone, [2, 0, 0, 0], fingers: [2, nil, nil, nil]),
        
        "F":      ChordShape.create("F",      .baritone, [3, 2, 1, 1], fingers: [3, 2, 1, 1]),
        "Fm":     ChordShape.create("Fm",     .baritone, [3, 1, 1, 1], fingers: [3, 1, 1, 1]),
        
        "G":      ChordShape.create("G",      .baritone, [0, 0, 0, 3], fingers: [nil, nil, nil, 3]),
        "Gm":     ChordShape.create("Gm",     .baritone, [0, 0, 3, 3], fingers: [nil, nil, 3, 4]),
        
        "A":      ChordShape.create("A",      .baritone, [2, 2, 2, 0], fingers: [1, 2, 3, nil]),
        "Am":     ChordShape.create("Am",     .baritone, [2, 2, 1, 0], fingers: [2, 3, 1, nil]),
        
        "B":      ChordShape.create("B",      .baritone, [4, 4, 4, 2], fingers: [2, 3, 4, 1]),
        "Bm":     ChordShape.create("Bm",     .baritone, [4, 4, 3, 2], fingers: [2, 3, 4, 1]),
    ]
    
    // Enharmonic Map
    private let enharmonics: [String: String] = [
        "C#": "Db", "Db": "C#",
        "D#": "Eb", "Eb": "D#",
        "F#": "Gb", "Gb": "F#",
        "G#": "Ab", "Ab": "G#",
        "A#": "Bb", "Bb": "A#",
        "C#m": "Dbm", "Dbm": "C#m",
        "D#m": "Ebm", "Ebm": "D#m",
        "F#m": "Gbm", "Gbm": "F#m",
        "G#m": "Abm", "Abm": "G#m",
        "A#m": "Bbm", "Bbm": "A#m"
    ]
    
    func getShape(for name: String, tuning: Tuning) -> ChordShape? {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Try Direct Match
        if let shape = lookup(cleanName, tuning: tuning) {
            return shape
        }
        
        // 2. Try Enharmonic
        if let alias = enharmonics[cleanName], let shape = lookup(alias, tuning: tuning) {
            return shape
        }
        
        return nil
    }
    
    private func lookup(_ name: String, tuning: Tuning) -> ChordShape? {
        switch tuning {
        case .tenor:    return tenorShapes[name]
        case .baritone: return baritoneShapes[name]
        }
    }
}
