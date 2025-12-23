
public protocol RenderCommandProtocol: Sendable {
    func render(renderer: borrowing some RendererProtocol & ~Copyable)
}