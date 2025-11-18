// swift-tools-version:6.2

import PackageDescription
import CompilerPluginSupport

// MARK: Targets
var targets:[Target] = [
    .systemLibrary(
        name: "CGLFW",
        pkgConfig: "glfw3",
        providers: [
            .brew(["glfw"]),
            .apt(["libglfw3", "libglfw3-dev"]),
        ]
    ),

    // MARK: GLFWRenderer
    .target(
        name: "GLFWRenderer",
        dependencies: [
            "SlayKit",
            "CGLFW",
            .product(name: "GL", package: "swift-opengl")
        ],
        linkerSettings: [
            .linkedLibrary("glfw"),
            .linkedLibrary("m"), // math
            .linkedLibrary("GL"), // Mesa / OpenGL
            .linkedLibrary("X11", .when(platforms: [.linux])) // common for GLFW on X11
        ]
    ),

    // MARK: SDLRenderer
    .target(
        name: "SDLRenderer",
        dependencies: [
            "SlayKit",
            .product(name: "SDL", package: "SwiftSDL2")
        ]
    ),

    // MARK: SlayKit
    .target(
        name: "SlayKit"
    ),

    // MARK: SlayMacros
    .macro(
        name: "SlayMacros",
        dependencies: [
            "SlayUI",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
        ]
    ),

    .target(
        name: "SlayUI"
    ),

    .target(
        name: "Slay",
        dependencies: [
            "SlayKit",
            "SlayMacros",
            "SlayUI"
        ]
    ),

    // MARK: Run
    .executableTarget(
        name: "Run",
        dependencies: [
            "Slay",
            "SlayKit",
            "SlayUI",

            "GLFWRenderer",
            "SDLRenderer"
        ]
    ),

    // MARK: SlayTests
    .testTarget(
        name: "SlayTests",
        dependencies: ["Slay"]
    )
]
for target in targets {
    if target.name != "CGLFW" {
        target.swiftSettings = [
            .enableExperimentalFeature("ExistentialAny")
        ]
    }
}

let package = Package(
    name: "slay",
    products: [
        .library(
            name: "Slay",
            targets: ["Slay"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ctreffs/SwiftSDL2", from: "1.4.1"),

        // GLFW C bindings and vendored build
        //.package(url: "https://github.com/ThePotatoKing55/CGLFW3", from: "3.4.0"),

        // Pure-Swift OpenGL loader (Linux-friendly)
        .package(url: "https://github.com/UnGast/swift-opengl", branch: "master"),

        // Macros
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0")
    ],
    targets: targets
)
