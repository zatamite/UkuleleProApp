// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UkulelePro",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "UkulelePro",
            targets: ["UkulelePro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit", from: "5.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "UkulelePro",
            dependencies: [
                "AudioKit",
                "AudioKitEX",
                "SoundpipeAudioKit",
            ],
            path: "UkulelePro",
            resources: [
                .process("Resources")
            ]),
    ]
)
