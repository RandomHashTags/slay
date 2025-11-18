
public struct Button {
    public var label:Label

    public init(_ label: Label) {
        self.label = label
    }
}

// MARK: View
extension Button: View {
    public var width: Int32 {
        label.width
    }

    public var height: Int32 {
        label.height
    }
}