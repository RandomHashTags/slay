
public struct StaticForEach<E: StaticView> {
    public var data:[E]
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
       backgroundColor: Color? = nil,
       data: () -> [E] = { [] }
    ) {
        let data = data()
        self.data = data

        var width:Int32? = 0
        var height:Int32? = 0
        for d in data {
            if let w = d.frame._width, width == nil || width! < w {
                width = w
            }
            if let h = d.frame._height, height == nil || height! < h {
                height = h
            }
        }
        frame = .init(width: width, height: height)
        self.backgroundColor = backgroundColor
    }
}