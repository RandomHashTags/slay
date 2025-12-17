
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
        let x0 = x
        let y0 = y
        let x1 = x + w
        let y1 = y + h
        return [
            x0, y1,  x1, y1,  x1, y0,
            x1, y0,  x0, y0,  x0, y1
        ]
    }
}