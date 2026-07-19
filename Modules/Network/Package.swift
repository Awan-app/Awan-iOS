// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        // Exposed as "Network" so consumers don't need to change their dependency declarations.
        .library(
            name: "Network",
            targets: ["AwaNetwork"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.10.0"
        ),
        .package(
            url: "https://github.com/auth0/SimpleKeychain.git",
            from: "1.3.0"
        )
    ],
    targets: [
        // Renamed from "Network" to "AwaNetwork" to avoid a circular-dependency error
        // caused by Alamofire's internal module also being named "Network".
        .target(
            name: "AwaNetwork",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SimpleKeychain", package: "SimpleKeychain")
            ]
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["AwaNetwork"]
        )
    ]
)
