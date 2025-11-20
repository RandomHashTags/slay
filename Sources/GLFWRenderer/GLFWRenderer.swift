
import CGLFW
import GL
import SlayKit

public struct GLFWRenderer: RendererProtocol, @unchecked Sendable {
    var queue:[RenderCommand] = []

    private var rectRenderer:RectRenderer! = nil
    private var textRenderer:TextRenderer? = nil

    public init() {
        check(glfwInit() == GLFW_TRUE)

        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
        #if os(Linux)
        // X11 by default; for Wayland, ensure GLFW was built with Wayland support
        #endif
    }
}

// MARK: Render
extension GLFWRenderer {
    public mutating func render(
        windowSettings: borrowing WindowSettings
    ) {
        let window = glfwCreateWindow(windowSettings.width, windowSettings.height, windowSettings.title, nil, nil)
        if window == nil {
            fatalError("Failed to create GLFW window")
        }
        glfwMakeContextCurrent(window)

        rectRenderer = RectRenderer(
            screenW: Float(windowSettings.width),
            screenH: Float(windowSettings.height)
        )

        if let atlas = FontAtlas(
            ttfPath: "/usr/share/fonts/Adwaita/AdwaitaMono-Regular.ttf",
            pixelSize: 16
        ) {
            textRenderer = TextRenderer(
                atlas: atlas,
                screenW: Float(windowSettings.width),
                screenH: Float(windowSettings.height)
            )
            queue.append(.text(text: "how much wood can a woodchuck chuck; peter piper picked a pack of picked peppers!", x: 100, y: 50, color: (0, 0, 0, 1)))
        } else {
            print("failed to load font")
        }

        // Main loop
        while glfwWindowShouldClose(window) == 0 {
            let width = windowSettings.width
            let height = windowSettings.height
            CGLFW.glViewport(0, 0, width, height)
            CGLFW.glClearColor(0.12, 0.12, 0.12, 1.0)
            CGLFW.glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

            for cmd in queue {
                switch cmd {
                case .rect(let frame, let radius, let color):
                    rectRenderer.draw(frame, color: color)
                case .text(let text, let x, let y, let color):
                    textRenderer?.draw(text, x: x, y: y, color: color)
                }
            }
            glfwSwapBuffers(window)
            glfwPollEvents()
        }
        glfwDestroyWindow(window)
        glfwTerminate()
    }
}

// MARK: Helpers
extension GLFWRenderer {
    func check(_ ok: Bool) {
        if !ok {
            fatalError("GLFW error")
        } 
    }
}

// MARK: Push command
extension GLFWRenderer {
    public mutating func push(_ cmd: RenderCommand) {
        queue.append(cmd)
    }
}