
public struct Section {
    public var text:Text
    public var data:[any Layoutable]

    public init(
        _ text: Text,
        data: [any Layoutable]
    ) {
        self.text = text
        self.data = data
    }
}

// MARK: Layoutable
extension Section: Layoutable {
    public var width: Int32 {
        data.max(by: { $0.width < $1.width })?.width ?? 0
    }

    public var height: Int32 {
        text.height + data.reduce(0, { $0 + $1.height })
    }
}