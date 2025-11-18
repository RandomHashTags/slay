
public struct VStack {
    public var data:[any View]

    public init(_ data: [any View]) {
        self.data = data
    }
}

// MARK: View
extension VStack: View {
    public var width: Int32 {
        data.max(by: { $0.width < $1.width })?.width ?? 0
    }

    public var height: Int32 {
        data.reduce(0, { $0 + $1.height })
    }
}