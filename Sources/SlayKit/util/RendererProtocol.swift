
public protocol RendererProtocol: Sendable, ~Copyable {
    mutating func render(
        fontAtlas: consuming FontAtlas,
        windowSettings: borrowing WindowSettings
    )

    mutating func push(
        _ cmd: RenderCommand
    )

    //mutating func end() -> [RenderCommand]
}