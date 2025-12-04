
public struct StaticVStack: StaticView {
    public var data:[any StaticView]
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        _ data: [any StaticView] = [],
        backgroundColor: Color? = nil
    ) {
        self.data = data
        frame = Self.calculateFrame(with: data)
        self.backgroundColor = backgroundColor
    }

    static func calculateFrame(with data: [any StaticView]) -> StaticRectangle {
        var width:Int32? = nil
        var height:Int32? = nil
        for d in data {
            if let w = d.frame._width, width == nil || width! < w {
                width = w
            }
            if let h = d.frame._height {
                height = (height ?? 0) + h
            }
        }
        return .init(width: width, height: height)
    }
}