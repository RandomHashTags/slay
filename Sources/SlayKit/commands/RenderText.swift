
public struct RenderText: RenderCommandProtocol {
    public let text:String
    public let x:Float
    public let y:Float
    public let color:(Float, Float, Float, Float)

    public init(
        text: String,
        x: Float,
        y: Float,
        color: (Float, Float, Float, Float)
    ) {
        self.text = text
        self.x = x
        self.y = y
        self.color = color
    }
}