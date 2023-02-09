// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EntCoreKit",
    products: [
        .library(name: "Keychain",
                 targets: ["Keychain"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Keychain",
                dependencies: []),
        .testTarget(name: "KeychainTests",
                    dependencies: ["Keychain"]),
    ]
)
