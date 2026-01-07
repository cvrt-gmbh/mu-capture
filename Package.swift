// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MikroskopCapture",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "MikroskopCapture",
            path: "Sources/MikroskopCapture"
        )
    ]
)
