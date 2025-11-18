
import CGLFW
import GL
import Slay

public struct GLFWRenderer: RendererProtocol, @unchecked Sendable {
    let vertexSrc = """
    #version 330 core
    layout (location = 0) in vec2 aPos; // NDC
    uniform vec4 uColor;
    out vec4 vColor;
    void main(){
        gl_Position = vec4(aPos, 0.0, 1.0);
        vColor = uColor;
    }
    """

    let fragSrc = """
    #version 330 core
    in vec4 vColor;
    out vec4 FragColor;
    void main(){ FragColor = vColor; }
    """

    private var vao:UInt32 = 0
    private var vbo:UInt32 = 0
    private var prog:UInt32 = 0

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
        windowSettings: borrowing WindowSettings,
        arena: Arena
    ) {
        let window = glfwCreateWindow(windowSettings.width, windowSettings.height, windowSettings.title, nil, nil)
        if window == nil {
            fatalError("Failed to create GLFW window")
        }
        glfwMakeContextCurrent(window)
        // GL loader (swift-opengl loads via libGL)

        // Build shader pipeline
        prog = linkProgram(
            vs: compileShader(vertexSrc, UInt32(GL_VERTEX_SHADER)),
            fs: compileShader(fragSrc, UInt32(GL_FRAGMENT_SHADER))
        )
        glGenVertexArrays(1, &vao)
        glGenBuffers(1, &vbo)

        // Main loop
        while glfwWindowShouldClose(window) == 0 {
            let width = windowSettings.width
            let height = windowSettings.height
            CGLFW.glViewport(0, 0, width, height)
            CGLFW.glClearColor(0.12, 0.12, 0.12, 1.0)
            CGLFW.glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

            for id in 1..<arena.nodes.count {
                let color:(Float, Float, Float, Float)
                switch id {
                case 1: color = (1, 0, 0, 1)
                case 2: color = (0, 1, 0, 1)
                case 3: color = (0, 0, 1, 1)
                default: color = (1, 1, 1, 1)
                }
                let rect = arena.layout(of: id)
                drawRect(rect, color: color, width: Float(width), height: Float(height))
            }
            glfwSwapBuffers(window)
            glfwPollEvents()
        }

        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)

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

    @discardableResult
    func compileShader(_ src: String, _ type: UInt32) -> UInt32 {
        let s = glCreateShader(Int32(type))
        var cString = Array(src.utf8CString)
        var len = GLint(src.utf8CString.count - 1)

        cString.withUnsafeMutableBufferPointer {
            let ba = UnsafePointer($0.baseAddress)
            withUnsafePointer(to: ba, { pp in
                withUnsafePointer(to: &len) { ll in
                    glShaderSource(s, 1, pp, ll)
                }
            })
        }
        glCompileShader(s)
        var status: GLint = 0
        glGetShaderiv(s, GL_COMPILE_STATUS, &status)
        if status == 0 {
            fatalError("Shader compile error")
        }
        return s
    }

    func linkProgram(vs: UInt32, fs: UInt32) -> UInt32 {
        let p = glCreateProgram()
        glAttachShader(p, vs)
        glAttachShader(p, fs)
        glLinkProgram(p)
        var status: GLint = 0
        glGetProgramiv(p, GL_LINK_STATUS, &status)
        if status == 0 {
            fatalError("Program link error")
        }
        glDeleteShader(vs)
        glDeleteShader(fs)
        return p
    }

    func ndc(
        _ x: Float,
        _ y: Float,
        _ w: Float,
        _ h: Float,
        _ W: Float,
        _ H: Float
    ) -> InlineArray<12, Float> {
        // top-left origin to OpenGL NDC (y up)
        let x1 = (x / W) * 2 - 1
        let y1 = 1 - (y / H) * 2
        let x2 = ((x + w) / W) * 2 - 1
        let y2 = 1 - ((y + h) / H) * 2
        // Two triangles
        return [ x1,y1,  x2,y1,  x2,y2,
                x2,y2,  x1,y2,  x1,y1 ]
    }

    func drawRect(
        _ rect: Rect,
        color: (Float, Float, Float, Float),
        width: Float,
        height: Float
    ) {
        var verts = ndc(rect.x, rect.y, rect.w, rect.h, width, height)
        glBindVertexArray(vao)
        glBindBuffer(GL_ARRAY_BUFFER, vbo)

        let vertsMS = verts.mutableSpan
        vertsMS.withUnsafeBytes {
            glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(vertsMS.count * MemoryLayout<Float>.size), $0.baseAddress, GL_DYNAMIC_DRAW)
        }
        glVertexAttribPointer(0, 2, GL_FLOAT, (GLboolean(GL_FALSE) != 0), 2 * GLsizei(MemoryLayout<Float>.size), nil)
        glEnableVertexAttribArray(0)
        glUseProgram(prog)
        let loc = glGetUniformLocation(prog, "uColor")

        var col:InlineArray<4, Float> = [color.0, color.1, color.2, color.3]
        let span = col.mutableSpan
        span.withUnsafeBufferPointer {
            glUniform4fv(loc, 1, UnsafePointer($0.baseAddress!))
        }
        glDrawArrays(UInt32(GL_TRIANGLES), 0, 6)
    }
}

// MARK: Push
extension GLFWRenderer {
    public func push(_ cmd: RenderCommand) {
        switch cmd {
        case .rect(let rect, let radius, let color):
            break
        }
    }
}