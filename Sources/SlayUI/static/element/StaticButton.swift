
public struct StaticButton: StaticView {
    public var label:StaticLabel
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        _ label: StaticLabel,
        backgroundColor: Color? = nil
    ) {
        self.label = label
        frame = label.frame
        self.backgroundColor = backgroundColor
    }
}