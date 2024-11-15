// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kyuuid",
    
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
    ],
    
    products: [
        .executable(name: "kyuuid", targets: ["kyuuid"]),
        .library(name: "UuidTools", targets: ["UuidTools"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    
    targets: [
        .target(
            name: "UuidTools",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
            ]
        ),
        
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



#if DEBUG
for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        .unsafeFlags([
            "-warnings-as-errors",
//            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
        ])
    )
}
#endif
