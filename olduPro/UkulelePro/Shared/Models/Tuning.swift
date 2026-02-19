import Foundation

enum Tuning: String, Codable, CaseIterable {
    case tenor = "tenor"
    case tenorLowG = "tenor_low_g"
    case baritone = "baritone"
    
    var displayName: String {
        switch self {
        case .tenor: return "Tenor (High-G)"
        case .tenorLowG: return "Tenor (Low-G)"
        case .baritone: return "Baritone"
        }
    }
    
    var stringNotes: [String] {
        switch self {
        case .tenor, .tenorLowG: return ["G", "C", "E", "A"]
        case .baritone: return ["D", "G", "B", "E"]
        }
    }
}
