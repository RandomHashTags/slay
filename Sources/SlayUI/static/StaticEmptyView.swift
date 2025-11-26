
public struct StaticEmptyView: StaticView {

    public var frame:StaticRectangle
    public var backgroundColor:Color? = nil

    public init(
        frame: StaticRectangle = .zero
    ) {
        self.frame = frame
    }
}