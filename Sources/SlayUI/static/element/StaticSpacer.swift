
public struct StaticSpacer: StaticView {
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        backgroundColor: Color? = nil
    ) {
        frame = .init(width: nil, height: nil)
        self.backgroundColor = backgroundColor
    }
}