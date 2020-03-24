// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "freq",
    platforms: [
        .macOS(.v10_13),
    ],
    dependencies: [
        .package(url: "https://github.com/ileitch/XCLogParser", .branch("direct-lib-usage")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/mxcl/Path.swift.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "freq",
            dependencies: [
                .product(name: "XCLogParser", package: "XCLogParser"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files"),
                .product(name: "Path", package: "Path.swift"),
            ]
        ),
        .testTarget(
            name: "freqTests",
            dependencies: ["freq"]),
    ]
)
