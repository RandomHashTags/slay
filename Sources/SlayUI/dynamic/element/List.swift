
public struct List {
    public var data:[any View]
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ data: [any View] = [],
        backgroundColor: Color? = nil
    ) {
        self.data = data

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
        frame = .init(width: width, height: height)
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension List: View {
}