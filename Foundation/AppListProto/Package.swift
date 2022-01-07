// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppListProto",
    products: [
        .library(
            name: "AppListProto",
            targets: ["AppListProto"]
        ),
    ],
    targets: [
        .target(
            name: "AppListProto",
            dependencies: []
        ),
    ]
)
