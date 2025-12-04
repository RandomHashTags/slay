
public struct StaticToggle: StaticView {
    public var text:StaticText
    public var image:StaticImage?
    public var isOn:Bool

    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        _ text: StaticText,
        image: StaticImage? = nil,
        isOn: Bool,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.image = image
        self.isOn = isOn
        frame = .init(
            width: text.frame.width + (image?.frame._width ?? 0), // TODO: what should the toggle switch width be?
            height: max(text.frame.height, image?.frame._height ?? 0) // TODO: what should the toggle switch height be?
        )
        self.backgroundColor = backgroundColor
    }
}