
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

    /// - Warning: `textVertices` always returns `(-1, -1)` because it contains multiple offsets in its `vertices` parameter.
    public var offset: (x: Float, y: Float) {
        switch self {
        case .rect(let frame, _, _):
            return (frame.x, frame.y)
        case .text(_, let x, let y, _):
            return (x, y)
        case .textVertices:
            return (-1, -1)
        }
    }
}