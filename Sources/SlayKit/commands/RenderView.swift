
public struct RenderView<each T: RenderCommandProtocol>: Sendable {
    public let commands:(repeat each T)

    public init(commands: (repeat each T)) {
        self.commands = commands
    }
}