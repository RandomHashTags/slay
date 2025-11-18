
public struct HStack {
    public var data:[any Layoutable]

    public init(_ data: [any Layoutable]) {
        self.data = data
    }
}

// MARK: Layoutable
extension HStack: Layoutable {
    public var width: Int32 {
        data.reduce(0, { $0 + $1.width })
    }

    public var height: Int32 {
        data.min(by: { $0.height < $1.height })?.height ?? 0
    }
}