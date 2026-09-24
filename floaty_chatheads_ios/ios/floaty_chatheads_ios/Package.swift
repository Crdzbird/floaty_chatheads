// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "floaty_chatheads_ios",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "floaty-chatheads-ios", targets: ["floaty_chatheads_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "floaty_chatheads_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            swiftSettings: [
            ]
        )
    ]
)