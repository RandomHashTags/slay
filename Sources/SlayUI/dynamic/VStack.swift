
public struct VStack {
    public var data:[any View]
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ data: [any View] = [],
        backgroundColor: Color? = nil
    ) {
        self.data = data
        frame = Self.calculateFrame(with: data)
        self.backgroundColor = backgroundColor
    }

    static func calculateFrame(with data: [any View]) -> Rectangle {
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

// MARK: View
extension VStack: View {
}