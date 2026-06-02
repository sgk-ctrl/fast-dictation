// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "fast-dictation",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "fast-dictate", targets: ["FastDictate"]),
        .executable(name: "fast-dictate-app", targets: ["FastDictateApp"]),
        .executable(name: "fast-dictate-selftest", targets: ["FastDictateSelfTest"]),
        .library(name: "FastDictateCore", targets: ["FastDictateCore"])
    ],
    targets: [
        .target(name: "FastDictateCore"),
        .executableTarget(
            name: "FastDictate",
            dependencies: ["FastDictateCore"]
        ),
        .executableTarget(
            name: "FastDictateApp",
            dependencies: ["FastDictateCore"]
        ),
        .executableTarget(
            name: "FastDictateSelfTest",
            dependencies: ["FastDictateCore"],
            path: "Tests/FastDictateTests"
        )
    ]
)
