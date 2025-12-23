
public struct RenderView<each T: RenderCommandProtocol>: RenderViewProtocol {
    public let commands:(repeat each T)

    public init(commands: (repeat each T)) {
        self.commands = commands
    }

    public func render(renderer: borrowing some RendererProtocol & ~Copyable) {
        for cmd in repeat each commands {
            cmd.render(renderer: renderer)
        }
    }
}