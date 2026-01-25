// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MuCapture",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "MuCapture",
            path: "Sources/MuCapture"
        )
    ]
)
