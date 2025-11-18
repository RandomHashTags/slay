
public struct VStack {
    public var data:[any View]
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ data: [any View],
        backgroundColor: Color? = nil
    ) {
        self.data = data

        var width:Int32 = 0
        var height:Int32 = 0
        for d in data {
            if width < d.frame._width {
                width = d.frame._width
            }
            height += d.frame._height
        }
        frame = .init(width: width, height: height)
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension VStack: View {
}