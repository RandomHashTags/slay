
public protocol RenderViewProtocol: Sendable {
    func render(renderer: borrowing some RendererProtocol & ~Copyable)
}