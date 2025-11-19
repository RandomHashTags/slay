
public protocol RendererProtocol: Sendable {
    mutating func render(
        windowSettings: borrowing WindowSettings
    )

    mutating func push(
        _ cmd: RenderCommand
    )

    //mutating func end() -> [RenderCommand]
}