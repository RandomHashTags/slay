
public struct Section {
    public var text:Text
    public var data:[any View]
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ text: Text,
        data: [any View],
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.data = data

        var width:Int32 = 0
        var height:Int32 = text.frame._height
        for d in data {
            if width < d.frame._width {
                width = d.frame._width
            }
            height += d.frame._height
        }
        frame = .init(
            width: width,
            height: height
        )
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Section: View {
}