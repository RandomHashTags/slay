
public struct Size: Sendable {
    public var width:Float?
    public var height:Float?

    public init(w: Float? = nil, h: Float? = nil) {
        self.width = w
        self.height = h
    }
}