
public struct Label {
    public var image:Image?
    public var text:Text
    public var frame:Rectangle

    public init(
        _ text: Text,
        image: Image?
    ) {
        self.text = text
        self.image = image

        frame = .init(
            width: (image?.frame._width ?? 0) + text.frame._width,
            height: min(image?.frame._height ?? 0, text.frame._height)
        )
    }
}

// MARK: View
extension Label: View {
}