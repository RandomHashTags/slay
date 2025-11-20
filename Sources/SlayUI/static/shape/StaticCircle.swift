
public struct StaticCircle: StaticView {
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        backgroundColor: Color? = nil
    ) {
        frame = .zero // TODO: fix
        self.backgroundColor = backgroundColor
    }
}