// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftAudioPlayer",
  platforms: [
    .iOS(.v10), .tvOS(.v10), .macOS(.v11),
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "SwiftAudioPlayer",
      targets: ["SwiftAudioPlayer"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),

    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.0.2"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SwiftAudioPlayer",
      dependencies: [
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Atomics", package: "swift-atomics")
      ],
      path: "Source"
    )
  ],
  swiftLanguageVersions: [.v5]
)
