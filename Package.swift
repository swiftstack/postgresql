// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PostgreSQL",
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/aio.git",
            .branch("master")),
        .package(
            url: "https://github.com/swift-stack/test.git",
            .branch("master"))
    ],
    targets: [
        .target(
            name: "PostgreSQL",
            dependencies: ["Network"]),
        .testTarget(
            name: "PostgreSQLTests",
            dependencies: ["Test", "PostgreSQL"])
    ]
)
