// swift-tools-version: 6.2
// The one library product. See docs/architecture/04-code.md#platforms for the versions it states.
import PackageDescription

let package = Package(
    name: "UITestingLibrary",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "UITestingLibrary", targets: ["UITestingLibrary"])
    ],
    targets: [
        .target(name: "UITestingLibrary")
    ],
    swiftLanguageModes: [.v6]
)
