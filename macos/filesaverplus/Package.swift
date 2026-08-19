// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "filesaverplus",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "filesaverplus", targets: ["filesaverplus"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "filesaverplus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
