
public struct Button {
    public var label:Label
    public var frame:Rectangle

    public init(_ label: Label) {
        self.label = label
        frame = label.frame
    }
}

// MARK: View
extension Button: View {
}