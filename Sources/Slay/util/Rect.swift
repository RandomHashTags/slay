
public struct Rect: Sendable {
    public var x:Float
    public var y:Float
    public var w:Float
    public var h:Float

    public init(
        x: Float,
        y: Float,
        w: Float,
        h: Float
    ) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
    }
}