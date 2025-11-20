
public struct StaticLabel: StaticView {
    public var image:StaticImage?
    public var text:StaticText
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        _ text: StaticText,
        image: StaticImage? = nil,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.image = image

        frame = .init(
            width: (image?.frame._width ?? 0) + text.frame.width,
            height: min(image?.frame._height ?? 0, text.frame.height)
        )
        self.backgroundColor = backgroundColor
    }
}