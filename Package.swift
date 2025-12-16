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
    .systemLibrary(
        name: "Freetype2",
        pkgConfig: "freetype2",
        providers: [
            .apt(["freetype2"])
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

    // MARK: DefaultViews
    .target(
        name: "DefaultViews",
        dependencies: [
            "SlayKit",
            "SlayMacros",
            "SlayUI",
            "Slay",
        ]
    ),

    // MARK: SlayKit
    .target(
        name: "SlayKit",
        dependencies: [
            "Freetype2"
        ]
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
        name: "SlayUI",
        dependencies: [
            "SlayKit"
        ]
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
            "DefaultViews",
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
        dependencies: [
            "DefaultViews",
            "Slay"
        ]
    )
]
for target in targets {
    if target.name != "CGLFW" && target.name != "Freetype2" {
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
