
import CGLFW
import GL
import SlayKit

public struct RectRenderer: GLFWRendererProtocol {
    var program:UInt32 = 0
    var vao:UInt32 = 0
    var vbo:UInt32 = 0
    let screenW:Float
    let screenH:Float

    public init(screenW: Float, screenH: Float) {
        self.screenW = screenW
        self.screenH = screenH
        setup()
    }
}

// MARK: Setup
extension RectRenderer {
    private mutating func setup() {
        let vs = """
        #version 330 core
        layout(location = 0) in vec2 aPos;
        out vec2 vPos;
        uniform vec2 uScreen;
        void main(){
            float x = (aPos.x / uScreen.x) * 2.0 - 1.0;
            float y = 1.0 - (aPos.y / uScreen.y) * 2.0;
            gl_Position = vec4(x, y, 0.0, 1.0);
            vPos = aPos;
        }
        """
        let fs = """
        #version 330 core
        out vec4 FragColor;
        uniform vec4 uColor;
        void main(){
            FragColor = uColor;
        }
        """
        let vertexShader = compileShader(vs, UInt32(GL_VERTEX_SHADER))
        let fragmentShader = compileShader(fs, UInt32(GL_FRAGMENT_SHADER))
        program = linkProgram(vertexShader: vertexShader, fragmentShader: fragmentShader)
        glGenVertexArrays(1, &vao)
        glGenBuffers(1, &vbo)
    }
}

// MARK: Draw
extension RectRenderer {
    public func draw(
        _ rect: Rect,
        color: (Float, Float, Float, Float)
    ) {
        glUseProgram(program)
        let locScreen = glGetUniformLocation(program, "uScreen")
        var screen = [screenW, screenH]
        glUniform2fv(locScreen, 1, &screen)
        let locColor = glGetUniformLocation(program, "uColor")
        withUnsafePointer(to: color) {
            glUniform4fv(locColor, 1, UnsafePointer<Float>(OpaquePointer($0)))
        }
        rect.vertices.span.withUnsafeBytes { buf in
            glBindVertexArray(vao)
            glBindBuffer(GL_ARRAY_BUFFER, vbo)
            glBufferData(GL_ARRAY_BUFFER, buf.count, buf.baseAddress, GL_DYNAMIC_DRAW)
            glVertexAttribPointer(0, 2, GL_FLOAT, false, 2 * GLsizei(MemoryLayout<Float>.size), nil)
            glEnableVertexAttribArray(0)
            glDrawArrays(GL_TRIANGLES, 0, 6)
        }
    }
}

extension RectRenderer {
    public func draw(
        _ rect: RenderRectangle
    ) {
        glUseProgram(program)
        let locScreen = glGetUniformLocation(program, "uScreen")
        var screen = [screenW, screenH]
        glUniform2fv(locScreen, 1, &screen)
        let locColor = glGetUniformLocation(program, "uColor")
        withUnsafePointer(to: rect.color) {
            glUniform4fv(locColor, 1, UnsafePointer<Float>(OpaquePointer($0)))
        }
        rect.frame.vertices.span.withUnsafeBytes { buf in
            glBindVertexArray(vao)
            glBindBuffer(GL_ARRAY_BUFFER, vbo)
            glBufferData(GL_ARRAY_BUFFER, buf.count, buf.baseAddress, GL_DYNAMIC_DRAW)
            glVertexAttribPointer(0, 2, GL_FLOAT, false, 2 * GLsizei(MemoryLayout<Float>.size), nil)
            glEnableVertexAttribArray(0)
            glDrawArrays(GL_TRIANGLES, 0, 6)
        }
    }
}

extension RectRenderer {
    public func draw(
        _ rect: RenderVertices
    ) {
        glUseProgram(program)
        let locScreen = glGetUniformLocation(program, "uScreen")
        var screen = [screenW, screenH]
        glUniform2fv(locScreen, 1, &screen)
        let locColor = glGetUniformLocation(program, "uColor")
        withUnsafePointer(to: rect.color) {
            glUniform4fv(locColor, 1, UnsafePointer<Float>(OpaquePointer($0)))
        }
        rect.vertices.withUnsafeBytes { buf in
            glBindVertexArray(vao)
            glBindBuffer(GL_ARRAY_BUFFER, vbo)
            glBufferData(GL_ARRAY_BUFFER, buf.count, buf.baseAddress, GL_DYNAMIC_DRAW)
            glVertexAttribPointer(0, 2, GL_FLOAT, false, 2 * GLsizei(MemoryLayout<Float>.size), nil)
            glEnableVertexAttribArray(0)
            glDrawArrays(GL_TRIANGLES, 0, 6)
        }
    }
}

extension RectRenderer {
    public func draw<let count: Int>(
        _ rect: RenderInlineVertices<count>
    ) {
        glUseProgram(program)
        let locScreen = glGetUniformLocation(program, "uScreen")
        var screen = [screenW, screenH]
        glUniform2fv(locScreen, 1, &screen)
        let locColor = glGetUniformLocation(program, "uColor")
        withUnsafePointer(to: rect.color) {
            glUniform4fv(locColor, 1, UnsafePointer<Float>(OpaquePointer($0)))
        }
        rect.vertices.span.withUnsafeBytes { buf in
            glBindVertexArray(vao)
            glBindBuffer(GL_ARRAY_BUFFER, vbo)
            glBufferData(GL_ARRAY_BUFFER, buf.count, buf.baseAddress, GL_DYNAMIC_DRAW)
            glVertexAttribPointer(0, 2, GL_FLOAT, false, 2 * GLsizei(MemoryLayout<Float>.size), nil)
            glEnableVertexAttribArray(0)
            glDrawArrays(GL_TRIANGLES, 0, 6)
        }
    }
}