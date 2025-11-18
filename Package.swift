// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "slay",
    products: [
        .library(
            name: "Slay",
            targets: ["Slay"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ctreffs/SwiftSDL2", from: "1.4.1"),

        // GLFW C bindings and vendored build
        //.package(url: "https://github.com/ThePotatoKing55/CGLFW3", from: "3.4.0"),

        // Pure-Swift OpenGL loader (Linux-friendly)
        .package(url: "https://github.com/UnGast/swift-opengl", branch: "master")
    ],
    targets: [
        .systemLibrary(
            name: "CGLFW",
            pkgConfig: "glfw3",
            providers: [
                .brew(["glfw"]),
                .apt(["libglfw3", "libglfw3-dev"]),
            ]
        ),

        .target(
            name: "GLFWRenderer",
            dependencies: [
                "Slay",
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

        .target(
            name: "SDLRenderer",
            dependencies: [
                .product(name: "SDL", package: "SwiftSDL2")
            ]
        ),

        .target(
            name: "Slay"
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                "Slay",

                "GLFWRenderer",
                "SDLRenderer"
            ]
        ),

        .testTarget(
            name: "SlayTests",
            dependencies: ["Slay"]
        ),
    ]
)
