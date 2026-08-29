// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-iso-21320",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "ISO 21320", targets: ["ISO 21320"]),
        .library(
            name: "ISO 21320 Standard Library Integration",
            targets: ["ISO 21320 Standard Library Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-ietf/swift-rfc-1951.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "ISO 21320",
            dependencies: [
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
                .product(name: "Byte", package: "swift-byte"),
                .product(
                    name: "Byte Standard Library Integration",
                    package: "swift-byte"
                ),
                .product(name: "RFC 1951", package: "swift-rfc-1951"),
            ]
        ),
        .target(
            name: "ISO 21320 Standard Library Integration",
            dependencies: [
                "ISO 21320",
                .product(
                    name: "Byte Standard Library Integration",
                    package: "swift-byte"
                ),
            ]
        ),
        .testTarget(
            name: "ISO 21320 Tests",
            dependencies: [
                "ISO 21320"
            ]
        ),
        .testTarget(
            name: "ISO 21320 Standard Library Integration Tests",
            dependencies: [
                "ISO 21320",
                "ISO 21320 Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
