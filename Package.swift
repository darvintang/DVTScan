// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVTScan",
    
    platforms: [
        .iOS(.v12)
    ],
    
    products: [
        .library(
            name: "DVTScan",
            targets: [
                "DVTScan"
            ]
        )
    ],
    
    dependencies: [
        .package(url: "https://github.com/darvintang/DVTUIKit.git", .upToNextMajor(from: "2.0.1"))
    ],
    
    targets: [
        .target(
            name: "DVTScan",
            dependencies: ["DVTUIKit"],
            path: "Sources"
        ),
        .testTarget(
            name: "DVTScanTests",
            dependencies: ["DVTScan"]
        )
    ]
)
