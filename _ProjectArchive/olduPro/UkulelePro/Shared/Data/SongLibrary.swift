import Foundation

class SongLibrary {
    static let shared = SongLibrary()
    
    let samples: [Song] = [
        Song(
            title: "Riptide",
            artist: "Vance Joy",
            rawContent: """
            [Am] I was scared of [G] dentists and the [C] dark
            [Am] I was scared of [G] pretty girls and [C] starting conversations
            Oh, [Am] all my [G] friends are turning [C] green
            You're the [Am] magician's [G] assistant in their [C] dream
            """
        ),
        Song(
            title: "Somewhere Over the Rainbow",
            artist: "Israel Kamakawiwo'ole",
            rawContent: """
            [C] Somewhere [Em] over the rainbow
            [F] Way up [C] high
            [F] And the [C] dreams that you dream of
            [G] Once in a lulla[Am]by [F]
            """
        )
    ]
}
