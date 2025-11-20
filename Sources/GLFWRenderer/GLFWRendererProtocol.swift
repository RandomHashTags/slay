
import CGLFW
import GL

protocol GLFWRendererProtocol {
}

extension GLFWRendererProtocol {
    func compileShader(
        _ src: String,
        _ type: UInt32
    ) -> UInt32 {
        let s = glCreateShader(GLMap.Enum(type))
        var cString = Array(src.utf8CString)
        cString.withUnsafeMutableBufferPointer { buf in
            var ptr = UnsafePointer<Int8>(buf.baseAddress)
            var len = GLint(buf.count - 1)
            glShaderSource(s, 1, &ptr, &len)
        }
        glCompileShader(s)
        var status:GLint = 0
        glGetShaderiv(s, GL_COMPILE_STATUS, &status)
        if status == 0 {
            fatalError("Shader compile failed")
        }
        return s
    }

    func linkProgram(
        vertexShader: UInt32,
        fragmentShader: UInt32
    ) -> UInt32 {
        let p = glCreateProgram()
        glAttachShader(p, vertexShader)
        glAttachShader(p, fragmentShader)
        glLinkProgram(p)
        var status:GLint = 0
        glGetProgramiv(p, GL_LINK_STATUS, &status)
        if status == 0 {
            fatalError("Program link failed")
        }
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        return p
    }
}