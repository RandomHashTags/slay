
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

    public var color: (Float, Float, Float, Float) {
        switch self {
        case .rect(_, _, let c): c
        case .text(_, _, _, let c): c
        case .textVertices(_, let c): c
        }
    }
}