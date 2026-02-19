import Foundation

enum Tuning: String, Codable, CaseIterable {
    case baritone = "baritone"
    case tenor = "tenor"
    
    var displayName: String {
        switch self {
        case .baritone: return "Baritone (D-G-B-E)"
        case .tenor: return "Tenor (G-C-E-A)"
        }
    }
    
    var stringNotes: [String] {
        switch self {
        case .baritone: return ["D", "G", "B", "E"]
        case .tenor: return ["G", "C", "E", "A"]
        }
    }
}
