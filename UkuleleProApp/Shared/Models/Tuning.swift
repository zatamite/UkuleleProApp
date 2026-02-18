import Foundation

enum Tuning: String, Codable, CaseIterable {
    case baritone = "baritone"
    
    var displayName: String {
        switch self {
        case .baritone: return "Baritone (D-G-B-E)"
        }
    }
    
    var stringNotes: [String] {
        switch self {
        case .baritone: return ["D", "G", "B", "E"]
        }
    }
}
