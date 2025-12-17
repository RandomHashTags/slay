
public protocol RendererProtocol: Sendable, ~Copyable {

    mutating func load(
        fontAtlas: consuming FontAtlas,
        windowSettings: borrowing WindowSettings
    )

    func render()

    mutating func push(
        _ cmd: RenderCommand
    )

    func render<let count: Int>(
        _ cmd: RenderInlineVertices<count>
    )

    //mutating func end() -> [RenderCommand]
}