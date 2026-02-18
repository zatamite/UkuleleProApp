import Foundation

struct ChordDatabase: Codable {
    let instrument: String
    let tuning: String
    let chords: [ChordTemplate]
}

struct ChordTemplate: Codable {
    let name: String
    let chroma: [Float]
    let notes: [String]
    
    // Helper to calculate similarity with another chroma vector
    func similarity(to otherChroma: [Float]) -> Float {
        guard chroma.count == 12, otherChroma.count == 12 else { return 0 }
        
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        
        for i in 0..<12 {
            dotProduct += chroma[i] * otherChroma[i]
            // Only positive weights contribute to the template's "magnitude".
            // Negative weights are pure penalties.
            if chroma[i] > 0 {
                normA += chroma[i] * chroma[i]
            }
            normB += otherChroma[i] * otherChroma[i]
        }
        
        let denom = sqrt(normA) * sqrt(normB)
        return denom > 0 ? dotProduct / denom : 0
    }
}
