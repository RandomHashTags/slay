
public struct HStack {
    public var data:[any View]

    public init(_ data: [any View]) {
        self.data = data
    }
}

// MARK: View
extension HStack: View {
    public var width: Int32 {
        data.reduce(0, { $0 + $1.width })
    }

    public var height: Int32 {
        data.max(by: { $0.height < $1.height })?.height ?? 0
    }
}