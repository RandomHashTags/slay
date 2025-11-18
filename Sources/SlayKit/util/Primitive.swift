
public struct Primitive: Sendable {
    public var frame:Rect
    public var kind:Kind

    public init(
        frame: Rect,
        kind: Kind
    ) {
        self.frame = frame
        self.kind = kind
    }
}

// MARK: Kind
extension Primitive {
    public enum Kind: Sendable {
        case box(background: (UInt8,UInt8,UInt8,UInt8))
    }
}