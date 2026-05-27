// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "floaty_chatheads_ios",
    platforms: [
        .iOS("14.0"),
    ],
    products: [
        .library(name: "floaty-chatheads-ios", targets: ["floaty_chatheads_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "floaty_chatheads_ios",
            dependencies: [],
            resources: [
            ],
            swiftSettings: [
            ]
        )
    ]
)