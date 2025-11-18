
public struct Button {
    public var label:Label

    public init(_ label: Label) {
        self.label = label
    }
}

// MARK: Layoutable
extension Button: Layoutable {
    public var width: Int32 {
        label.width
    }

    public var height: Int32 {
        label.height
    }
}