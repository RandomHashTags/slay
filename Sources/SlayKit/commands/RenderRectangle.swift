
public struct RenderRectangle: RenderCommandProtocol {
    public let frame:Rect
    public let radius:Float
    public let color:(Float, Float, Float, Float)

    public init(
        frame: Rect,
        radius: Float,
        color: (Float, Float, Float, Float)
    ) {
        self.frame = frame
        self.radius = radius
        self.color = color
    }
}