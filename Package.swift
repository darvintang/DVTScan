// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVTScan",
    
    platforms: [
        .iOS(.v13)
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
        .package(url: "https://github.com/darvintang/DVTUIKit.git", .upToNextMinor(from: "2.0.0"))
    ],
    
    targets: [
        .target(
            name: "DVTScan",
            dependencies: [
                .product(name: "DVTUIKit.Extension", package: "DVTUIKit")
            ],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("Vision")
            ]
        ),
        .testTarget(
            name: "DVTScanTests",
            dependencies: ["DVTScan"]
        )
    ]
)
