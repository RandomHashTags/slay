
public struct RenderInlineVertices<let count: Int>: RenderCommandProtocol {
    public let vertices:[count of Float]
    public let color:(Float, Float, Float, Float)

    public init(
        vertices: [count of Float],
        color: (Float, Float, Float, Float)
    ) {
        self.vertices = vertices
        self.color = color
    }
}