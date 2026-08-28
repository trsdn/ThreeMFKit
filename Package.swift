// swift-tools-version: 6.0
import PackageDescription

/// Shared 3MF package reading and preview extraction.
///
/// This used to be a directory of sources that the app project compiled by relative path, which
/// meant the two Xcode projects had to stay siblings on disk, the same files were compiled into
/// three separate binaries as unrelated module types, and each project pinned ZIPFoundation
/// independently. As a package it is one versioned dependency with one pin.
let package = Package(
    name: "ThreeMFKit",
    platforms: [.macOS(.v15)],
    products: [
        // Static so consumers link the code in rather than embedding a package-product
        // framework. A dynamic product produces a versioned framework bundle containing
        // symlinks, which the notarization broker's preflight rejects outright.
        .library(name: "ThreeMFKit", type: .static, targets: ["ThreeMFKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19")
    ],
    targets: [
        // The module must stay within the API surface an app extension may link, because it is
        // consumed by Quick Look preview and thumbnail extensions. That used to be enforced with
        // .unsafeFlags(["-application-extension"]), which SwiftPM refuses to allow in a package
        // consumed by version from a remote repository -- it only worked while this was a local
        // path dependency, and it silently blocked the split into its own repository.
        //
        // The guarantee now lives in CI, which builds with `-Xswiftc -application-extension`, and
        // in the consumers, whose extension targets already set APPLICATION_EXTENSION_API_ONLY.
        .target(
            name: "ThreeMFKit",
            dependencies: ["ZIPFoundation"]
        ),
        .testTarget(
            name: "ThreeMFKitTests",
            dependencies: ["ThreeMFKit", "ZIPFoundation"]
        )
    ]
)
