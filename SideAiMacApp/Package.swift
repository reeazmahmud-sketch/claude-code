// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SideAiMacApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SideAiMacApp",
            targets: ["SideAiMacApp"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SideAiMacApp",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SideAiMacAppTests",
            dependencies: ["SideAiMacApp"],
            path: "Tests"
        )
    ]
)
