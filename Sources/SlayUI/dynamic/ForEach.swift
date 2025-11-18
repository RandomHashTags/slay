
public struct ForEach<E: View> {
    public var data:[E]
    public var frame:Rectangle

    public init(
       data: [E]
    ) {
        self.data = data

        var width:Int32 = 0
        var height:Int32 = 0
        for d in data {
            if width < d.frame._width {
                width = d.frame._width
            }
            if height < d.frame._height {
                height = d.frame._height
            }
        }
        frame = .init(width: width, height: height)
    }
}

// MARK: View
extension ForEach: View {
}