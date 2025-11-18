
public struct ForEach<E: Layoutable> {
    public var data:[E]

    public init(
       data: [E]
    ) {
        self.data = data
    }
}

// MARK: Layoutable
extension ForEach: Layoutable {
    public var width: Int32 {
        data.max(by: { $0.width < $1.width })?.width ?? 0
    }

    public var height: Int32 {
        data.reduce(0, { $0 + $1.height })
    }
}