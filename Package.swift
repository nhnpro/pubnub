// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PubNub",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PubNub",
            targets: ["PubNub"]),
        .library(
          name: "PubNubUser",
          targets: ["PubNubUser"]
        ),
        .library(
          name: "PubNubSpace",
          targets: ["PubNubSpace"]
        ),
        .library(
          name: "PubNubMembership",
          targets: ["PubNubMembership"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PubNub"), 
        .target(
            name: "PubNubUser",
            dependencies: ["PubNub"]
        ),
        .target(
            name: "PubNubSpace",
            dependencies: ["PubNub"]
        ),
        .target(
            name: "PubNubMembership",
            dependencies: ["PubNub", "PubNubUser", "PubNubSpace"]
        ),
    ]
)
