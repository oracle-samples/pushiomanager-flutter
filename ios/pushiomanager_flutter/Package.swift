// swift-tools-version: 5.9
// Copyright © 2026 Oracle Inc. All rights reserved.

import PackageDescription

let package = Package(
    name: "pushiomanager_flutter",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "pushiomanager-flutter",
            targets: ["pushiomanager_flutter"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "pushiomanager_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "CXMobileSDK"
            ],
            linkerSettings: [
                .unsafeFlags(["-ObjC"]),
                .linkedLibrary("sqlite3"),
                .linkedFramework("UserNotifications"),
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("WebKit")
            ]
        ),
        .binaryTarget(
            name: "CXMobileSDK",
            path: "CXMobileSDK.xcframework"
        )
    ]
)
