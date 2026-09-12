// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BibleKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
        .watchOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BibleKit",
            targets: ["BibleKit"]
        ),
        .library(
            name: "BibleKitSword",
            targets: ["BibleKitSword"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/orbeavers14/SwordKit.git", from: "0.6.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BibleKit"
        ),
        .target(
            name: "BibleKitSword",
            dependencies: [
                "BibleKit",
                .product(name: "SwordKit", package: "SwordKit"),
            ]
        ),
        .testTarget(
            name: "BibleKitTests",
            dependencies: ["BibleKit"]
        ),
        .testTarget(
            name: "BibleKitSwordTests",
            dependencies: [
                "BibleKitSword",
                .product(name: "SwordKit", package: "SwordKit"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
