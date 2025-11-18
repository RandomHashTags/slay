
public struct Label {
    public var image:Image?
    public var text:Text
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ text: Text,
        image: Image? = nil,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.image = image

        frame = .init(
            width: (image?.frame._width ?? 0) + text.frame._width,
            height: min(image?.frame._height ?? 0, text.frame._height)
        )
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Label: View {
}