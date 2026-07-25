# swift-iso-21320

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The ZIP-based document-container core profile of ISO/IEC 21320-1.

## Standard Reference

- **ISO/IEC**: 21320-1
- **Title**: Document Container File — Core

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-iso/swift-iso-21320.git", from: "0.0.1")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "ISO 21320", package: "swift-iso-21320")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
