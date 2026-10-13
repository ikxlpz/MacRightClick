// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RightAction",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RightActionCore",
            targets: ["RightActionCore"]
        )
    ],
    targets: [
        .target(
            name: "RightActionCore",
            path: "Sources/RightAction/Core"
        ),
        .testTarget(
            name: "RightActionTests",
            dependencies: ["RightActionCore"],
            path: "Tests",
            exclude: [
                "CaskStructureTests.sh",
                "ReleaseWorkflowStructureTests.sh"
            ]
        )
    ]
)
