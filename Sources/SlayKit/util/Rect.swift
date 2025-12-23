
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

    public var vertices: [12 of Float] {
        let x1 = x + w
        let y1 = y + h
        return [
            x, y1,  x1, y1,  x1, y,
            x1, y,  x, y,  x, y1
        ]
    }
}