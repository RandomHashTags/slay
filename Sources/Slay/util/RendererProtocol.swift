
public protocol RendererProtocol: Sendable {
    mutating func render(
        windowSettings: borrowing WindowSettings,
        arena: Arena
    )

    mutating func push(
        _ cmd: RenderCommand
    )

    //mutating func end() -> [RenderCommand]
}