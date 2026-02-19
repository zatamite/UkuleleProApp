import Foundation

struct ChordDetectionResult: Codable {
    let chordName: String
    let confidence: Float
    let chromaVector: [Float]
    let timestamp: Date
}
