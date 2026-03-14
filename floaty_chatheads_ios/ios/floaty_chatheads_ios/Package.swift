// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "floaty_chatheads_ios",
    platforms: [
        .iOS("13.0"),
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