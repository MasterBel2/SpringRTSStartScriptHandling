// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpringRTSStartScriptHandling",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SpringRTSStartScriptHandling",
            targets: ["SpringRTSStartScriptHandling"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MasterBel2/CountryCode", .branch("master")),
        .package(url: "https://github.com/MasterBel2/ServerAddress", .branch("master"))
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SpringRTSStartScriptHandling",
            dependencies: ["CountryCode", "ServerAddress"]),
        .testTarget(
            name: "SpringRTSStartScriptHandlingTests",
            dependencies: ["SpringRTSStartScriptHandling"]),
    ]
)
