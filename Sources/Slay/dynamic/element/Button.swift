
public struct Button {
    public var text:Text

    public init(_ text: Text) {
        self.text = text
    }
}

// MARK: Layoutable
extension Button: Layoutable {
    public var width: Int32 {
        text.width
    }

    public var height: Int32 {
        text.height
    }
}