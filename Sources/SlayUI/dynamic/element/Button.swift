
public struct Button {
    public var label:Label
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ label: Label,
        backgroundColor: Color? = nil
    ) {
        self.label = label
        frame = label.frame
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Button: View {
}