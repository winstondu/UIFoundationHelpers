// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WinstonUIFoundation",
    platforms: [
        .iOS(.v17),
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
