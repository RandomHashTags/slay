
public struct RenderView<each T: RenderCommandProtocol>: RenderViewProtocol {
    public let commands:(repeat each T)

    public init(commands: (repeat each T)) {
        self.commands = commands
    }
}