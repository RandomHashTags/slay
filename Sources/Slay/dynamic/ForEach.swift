
public struct ForEach<E: View> {
    public var data:[E]

    public init(
       data: [E]
    ) {
        self.data = data
    }
}

// MARK: View
extension ForEach: View {
    public var width: Int32 {
        data.max(by: { $0.width < $1.width })?.width ?? 0
    }

    public var height: Int32 {
        data.reduce(0, { $0 + $1.height })
    }
}