// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kyuuid",
    
    platforms: [
        .macOS(.v13)
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "UuidTools"),
        
        .executableTarget(
            name: "kyuuid",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "UuidTools"),
            ]
        ),
        
        .testTarget(
            name: "UuidToolsTests",
            dependencies: [
                .target(name: "UuidTools")
            ]
        ),
    ]
)



for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        .unsafeFlags([
            "-warnings-as-errors",
//            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
            "-enable-bare-slash-regex",
        ])
    )
}
