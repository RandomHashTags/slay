
import CGLFW
import GL
import SlayKit

// https://learnopengl.com/In-Practice/Text-Rendering
public struct TextRenderer: GLFWRendererProtocol, ~Copyable {
    public var texture:UInt32 = 0
    public var vao:UInt32 = 0
    public var vbo:UInt32 = 0
    public var program:UInt32 = 0
    public var atlas:FontAtlas
    public var screenW:Float
    public var screenH:Float

    public init(
        atlas: consuming FontAtlas,
        screenW: Float,
        screenH: Float
    ) {
        self.atlas = atlas
        self.screenW = screenW
        self.screenH = screenH
        setup()
    }
}

// MARK: Setup
extension TextRenderer {
    private mutating func setup() {
        let vs = """
        #version 330 core
        layout(location = 0) in vec2 aPos;
        layout(location = 1) in vec2 aUV;
        out vec2 vUV;
        uniform vec2 uScreen;
        void main(){
            float x = (aPos.x / uScreen.x) * 2.0 - 1.0;
            float y = 1.0 - (aPos.y / uScreen.y) * 2.0;
            gl_Position = vec4(x, y, 0.0, 1.0);
            vUV = aUV;
        }
        """
        let fs = """
        #version 330 core
        in vec2 vUV;
        out vec4 FragColor;
        uniform sampler2D uAtlas;
        uniform vec4 uColor;
        void main(){
            float a = texture(uAtlas, vUV).r;
            FragColor = vec4(uColor.rgb, uColor.a * a);
        }
        """
        let vertexShader = compileShader(vs, UInt32(GL_VERTEX_SHADER))
        let fragmentShader = compileShader(fs, UInt32(GL_FRAGMENT_SHADER))
        program = linkProgram(vertexShader: vertexShader, fragmentShader: fragmentShader)

        glGenVertexArrays(1, &vao)
        glGenBuffers(1, &vbo)

        // upload atlas texture
        glGenTextures(1, &texture)
        glBindTexture(GL_TEXTURE_2D, texture)
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1)
        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            GL_RED,
            GLsizei(atlas.textureWidth),
            GLsizei(atlas.textureHeight),
            0,
            GL_RED,
            GL_UNSIGNED_BYTE,
            atlas.pixelData
        )
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    }
}

// MARK: Prepare draw
extension TextRenderer {
    private func prepareDraw(color: (Float, Float, Float, Float)) {
        glUseProgram(program)
        let locScreen = glGetUniformLocation(program, "uScreen")
        var screen = [screenW, screenH]
        glUniform2fv(locScreen, 1, &screen)
        let locColor = glGetUniformLocation(program, "uColor")
        var col = [color.0, color.1, color.2, color.3]
        glUniform4fv(locColor, 1, &col)
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture)
        let uAtlasLoc = glGetUniformLocation(program, "uAtlas")
        var zero:GLint = 0
        glUniform1i(uAtlasLoc, zero)
        glBindVertexArray(vao)
        glBindBuffer(GL_ARRAY_BUFFER, vbo)
    }
}

// MARK: Draw
extension TextRenderer {
    public func draw(
        _ text: String,
        x: Float,
        y: Float,
        color: (Float, Float, Float, Float)
    ) {
        prepareDraw(color: color)

        var x = x
        var vertices = [Float]() // x,y,u,v per vertex (6 vertices per glyph)
        for scalar in text.unicodeScalars {
            guard let glyph = atlas.glyphs[UInt32(scalar.value)] else { continue }
            let gx = Float(glyph.atlasX)
            let gy = Float(glyph.atlasY)
            let gw = Float(glyph.width)
            let gh = Float(glyph.height)

            let u0 = gx / Float(atlas.textureWidth)
            let u1 = (gx + gw) / Float(atlas.textureWidth)

            let v0 = (gy + gh) / Float(atlas.textureHeight)
            let v1 = gy / Float(atlas.textureHeight)

            let x0 = x + Float(glyph.bearingX)
            let y0 = y - Float(glyph.bearingY) + Float(glyph.height)
            let x1 = x0 + gw
            let y1 = y0 - gh

            // two triangles
            vertices += [x0, y1, u0, v1,  x1, y1, u1, v1,  x1, y0, u1, v0]
            vertices += [x1, y0, u1, v0,  x0, y0, u0, v0,  x0, y1, u0, v1]

            x += Float(glyph.advance)
        }
        guard !vertices.isEmpty else { return }
        drawVertices(vertices)
    }
}

// MARK: Draw verts
extension TextRenderer {
    /// - Warning: Doesn't check if `verts` is empty!
    public func draw(
        _ verts: [Float],
        color: (Float, Float, Float, Float)
    ) {
        prepareDraw(color: color)
        drawVertices(verts)
    }

    private func drawVertices(
        _ verts: [Float]
    ) {
        verts.withUnsafeBytes { buf in
            glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(buf.count), buf.baseAddress, GL_DYNAMIC_DRAW)
        }
        let stride = GLsizei(MemoryLayout<Float>.size * 4)
        glVertexAttribPointer(0, 2, GL_FLOAT, false, stride, nil)
        let uvOffset = UnsafeRawPointer(bitPattern: MemoryLayout<Float>.size * 2)
        glVertexAttribPointer(1, 2, GL_FLOAT, false, stride, uvOffset)
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glDrawArrays(GL_TRIANGLES, 0, GLsizei(verts.count / 4))
    }
}