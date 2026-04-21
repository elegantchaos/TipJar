// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "TipJar",
  platforms: [
    .macOS(.v26), .iOS(.v26), .tvOS(.v26),
  ],
  products: [
    .library(name: "TipJar", targets: ["TipJar"]),
    .library(name: "TipJarUI", targets: ["TipJarUI"]),
    .library(name: "TipJarLocalStore", targets: ["TipJarLocalStore"]),
    .library(name: "TipJarUbiquitousStore", targets: ["TipJarUbiquitousStore"]),
    .library(name: "TipJarSwiftData", targets: ["TipJarSwiftData"]),
  ],
  dependencies: [
    .package(url: "https://github.com/elegantchaos/Commands.git", from: "2.0.0"),
    .package(url: "https://github.com/elegantchaos/Icons.git", from: "1.0.1"),
    .package(url: "https://github.com/elegantchaos/Logger.git", from: "2.0.4"),
  ],
  targets: [
    .target(
      name: "TipJar",
      dependencies: [
        .product(name: "Commands", package: "Commands"),
        .product(name: "Logger", package: "Logger"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]
    ),
    .target(
      name: "TipJarUI",
      dependencies: [
        "TipJar",
        .product(name: "Commands", package: "Commands"),
        .product(name: "CommandsUI", package: "Commands"),
        .product(name: "Icons", package: "Icons"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]
    ),
    .target(
      name: "TipJarLocalStore",
      dependencies: ["TipJar"],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]
    ),
    .target(
      name: "TipJarUbiquitousStore",
      dependencies: ["TipJar"],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]
    ),
    .target(
      name: "TipJarSwiftData",
      dependencies: ["TipJar"],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]
    ),
    .testTarget(
      name: "TipJarTests",
      dependencies: [
        "TipJar",
        "TipJarLocalStore",
        "TipJarUbiquitousStore",
        "TipJarSwiftData",
        "TipJarUI",
      ]
    ),
  ]
)
