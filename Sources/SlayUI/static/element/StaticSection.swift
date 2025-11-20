
public struct StaticSection: StaticView {
    public var text:StaticText
    public var data:[any StaticView]
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        _ text: StaticText,
        data: [any StaticView],
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.data = data

        var width:Int32? = 0
        var height:Int32? = text.frame._height
        for d in data {
            if let w = d.frame._width, width == nil || width! < w {
                width = w
            }
            if let h = d.frame._height {
                height = (height ?? 0) + h
            }
        }
        frame = .init(
            width: width,
            height: height
        )
        self.backgroundColor = backgroundColor
    }
}