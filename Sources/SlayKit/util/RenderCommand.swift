
public enum RenderCommand: Sendable {
    case rect(
        frame: Rect,
        radius: Float,
        color: (Float, Float, Float, Float)
    )

    case text(
        text: String,
        x: Float,
        y: Float,
        color: (Float, Float, Float, Float)
    )

    case textVertices(
        vertices: [Float],
        color: (Float, Float, Float, Float)
    )
}