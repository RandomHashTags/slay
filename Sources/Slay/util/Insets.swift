
public struct Insets: Sendable {
    public var left:Float
    public var top:Float
    public var right:Float
    public var bottom:Float

    public init(
        left: Float,
        top: Float,
        right: Float,
        bottom: Float
    ) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }

    public static let zero = Insets(left: 0, top: 0, right: 0, bottom: 0)
}