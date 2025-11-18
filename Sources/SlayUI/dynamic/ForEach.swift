
public struct ForEach<E: View> {
    public var data:[E]
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
       _ data: [E],
       backgroundColor: Color? = nil
    ) {
        self.data = data

        var width:Int32 = 0
        var height:Int32 = 0
        for d in data {
            if width < d.frame.width {
                width = d.frame.width
            }
            if height < d.frame.height {
                height = d.frame.height
            }
        }
        frame = .init(width: width, height: height)
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension ForEach: View {
}