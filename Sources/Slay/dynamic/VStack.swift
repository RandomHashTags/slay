
public struct VStack {
    public var data:[any Layoutable]

    public init(_ data: [any Layoutable]) {
        self.data = data
    }
}

// MARK: Layoutable
extension VStack: Layoutable {
    public var width: Int32 {
        data.max(by: { $0.width < $1.width })?.width ?? 0
    }

    public var height: Int32 {
        data.reduce(0, { $0 + $1.height })
    }
}