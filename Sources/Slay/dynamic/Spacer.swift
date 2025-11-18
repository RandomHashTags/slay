
public struct Spacer {
    public init() {
    }
}

// MARK: Layoutable
extension Spacer: Layoutable {
    public var width: Int32 {
        0
    }

    public var height: Int32 {
        0
    }
}