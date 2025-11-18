
public enum RenderCommand: Sendable {
    case rect(frame: Rect, radius: Float, bg: (UInt8, UInt8, UInt8, UInt8))
}