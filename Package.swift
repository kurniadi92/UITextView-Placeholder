// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UITextViewPlaceholder",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "UITextViewPlaceholder",
            targets: ["UITextViewPlaceholder"]),
    ],
    targets: [
        .target(
            name: "UITextViewPlaceholder",
            path: "Sources/UITextViewPlaceholder",
            publicHeadersPath: "."
        )
    ]
)
