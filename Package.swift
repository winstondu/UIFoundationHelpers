// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "WinstonUIFoundation",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "WinstonUIFoundation",
            targets: ["WinstonUIFoundation"]
        ),
    ],
    targets: [
        .target(
            name: "WinstonUIFoundation",
            path: "."
        ),
    ]
)
