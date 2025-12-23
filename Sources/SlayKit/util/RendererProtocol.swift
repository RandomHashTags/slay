
public protocol RendererProtocol: Sendable, ~Copyable {

    mutating func load(
        fontAtlas: consuming FontAtlas,
        windowSettings: borrowing WindowSettings
    )

    func render()

    mutating func push(
        _ cmd: RenderCommand
    )

    func render(
        _ cmd: RenderRectangle
    )

    func render<let count: Int>(
        _ cmd: RenderInlineVertices<count>
    )

    func render(
        _ cmd: RenderVertices
    )

    //mutating func end() -> [RenderCommand]
}