
import CGLFW
import GL
import SlayKit

public struct GLFWRenderer: ~Copyable, RendererProtocol, @unchecked Sendable {
    var queue = [RenderCommand]()

    private var rectRenderer:RectRenderer! = nil
    private var textRenderer:TextRenderer? = nil

    private var window:OpaquePointer! = nil

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

// MARK: Load
extension GLFWRenderer {
    public mutating func load(
        fontAtlas: consuming FontAtlas,
        windowSettings: borrowing WindowSettings,
    ) {
        //glfwWindowHint(GLFW_DOUBLEBUFFER, GLFW_FALSE)
        //glfwSwapInterval(0)
        window = glfwCreateWindow(windowSettings.width, windowSettings.height, windowSettings.title, nil, nil)
        if window == nil {
            fatalError("Failed to create GLFW window")
        }
        glfwMakeContextCurrent(window)

        rectRenderer = RectRenderer(
            screenW: Float(windowSettings.width),
            screenH: Float(windowSettings.height)
        )

        textRenderer = TextRenderer(
            atlas: fontAtlas,
            screenW: Float(windowSettings.width),
            screenH: Float(windowSettings.height)
        )

        let width = windowSettings.width
        let height = windowSettings.height
        CGLFW.glViewport(0, 0, width, height)
        CGLFW.glClearColor(0.12, 0.12, 0.12, 1.0)
        CGLFW.glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glfwSwapBuffers(window)
    }
}

// MARK: Render
extension GLFWRenderer {
    public func render() {
        // Main loop
        while glfwWindowShouldClose(window) == 0 {
            CGLFW.glClearColor(0.12, 0.12, 0.12, 1.0)
            CGLFW.glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

            for cmd in queue {
                switch cmd {
                case .rect(let frame, let radius, let color):
                    rectRenderer.draw(frame, color: color)
                case .text(let text, let x, let y, let color):
                    textRenderer?.draw(text, x: x, y: y, color: color)
                case .textVertices(let vertices, let color):
                    textRenderer?.draw(vertices, color: color)
                }
            }
            glfwSwapBuffers(window)
            glfwPollEvents()
        }
        glfwDestroyWindow(window)
        glfwTerminate()
    }

    public func newRender() {
        /*var needsRedraw = true
        glfwSetKeyCallback(window) { _, _, _, _, _ in
            needsRedraw = true
        }

        glfwSetFramebufferSizeCallback(window) { _, _, _ in
            needsRedraw = true
        }
        while glfwWindowShouldClose(window) == 0 {
            glfwSwapBuffers(window)
            glfwPollEvents()
        }
        glfwDestroyWindow(window)
        glfwTerminate()*/
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

// MARK: Extensions
extension GLFWRenderer {
    public func render(
        _ cmd: RenderRectangle
    ) {
        rectRenderer.draw(cmd)
    }

    public func render<let count: Int>(
        _ cmd: RenderInlineVertices<count>
    ) {
        rectRenderer.draw(cmd)
    }

    public func render(
        _ cmd: RenderVertices
    ) {
        rectRenderer.draw(cmd)
    }
}