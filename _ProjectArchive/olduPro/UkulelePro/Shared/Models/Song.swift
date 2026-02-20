import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let lines: [SongLine]
    
    init(id: UUID = UUID(), title: String, artist: String, rawContent: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.lines = Song.parse(rawContent)
    }
    
    private static func parse(_ raw: String) -> [SongLine] {
        let rawLines = raw.components(separatedBy: .newlines)
        return rawLines.map { line in
            var segments: [SongSegment] = []
            let scanner = Scanner(string: line)
            scanner.charactersToBeSkipped = nil
            
            while !scanner.isAtEnd {
                if let _ = scanner.scanString("[") {
                    if let chord = scanner.scanUpToString("]") {
                        _ = scanner.scanString("]")
                        segments.append(.chord(chord))
                    }
                } else if let lyric = scanner.scanUpToString("[") {
                    segments.append(.lyric(lyric))
                } else if let remaining = scanner.scanCharacters(from: .init(charactersIn: "[")) {
                    // This handles potential single [ characters if any
                    segments.append(.lyric(remaining))
                    break
                }
            }
            return SongLine(segments: segments)
        }
    }
}

struct SongLine: Identifiable, Codable {
    let id: UUID
    let segments: [SongSegment]
    
    init(id: UUID = UUID(), segments: [SongSegment]) {
        self.id = id
        self.segments = segments
    }
}

enum SongSegment: Codable {
    case lyric(String)
    case chord(String)
}
