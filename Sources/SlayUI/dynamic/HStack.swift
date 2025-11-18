
public struct HStack {
    public var data:[any View]
    public var frame:Rectangle

    public init(_ data: [any View]) {
        self.data = data

        var width:Int32 = 0
        var height:Int32 = 0
        for d in data {
            width += d.frame._width
            if height < d.frame._height {
                height = d.frame._height
            }
        }
        frame = .init(width: width, height: height)
    }
}

// MARK: View
extension HStack: View {
}