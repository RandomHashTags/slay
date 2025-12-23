
public struct RenderVertices: RenderCommandProtocol {
    public let vertices:[Float]
    public let color:(Float, Float, Float, Float)

    public init(
        vertices: [Float],
        color: (Float, Float, Float, Float)
    ) {
        self.vertices = vertices
        self.color = color
    }

    public func render(renderer: borrowing some RendererProtocol & ~Copyable) {
        // TODO: fix
    }
}