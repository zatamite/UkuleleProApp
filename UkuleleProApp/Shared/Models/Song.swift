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
                        // After a chord, there might be text. We grab until the next chord.
                        let text = scanner.scanUpToString("[") ?? ""
                        segments.append(.chorded(chord: chord, text: text))
                    }
                } else {
                    if let plain = scanner.scanUpToString("[") {
                        segments.append(.text(plain))
                    } else {
                        // Handle remaining text
                        let remaining = scanner.string.suffix(from: scanner.currentIndex)
                        if !remaining.isEmpty {
                            segments.append(.text(String(remaining)))
                        }
                        break
                    }
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
    case text(String)
    case chorded(chord: String, text: String)
}
