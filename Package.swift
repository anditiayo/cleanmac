// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CleanMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CleanMac", targets: ["CleanMac"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CleanMac",
            dependencies: [],
            path: "Sources/CleanMac"
        )
    ]
)

