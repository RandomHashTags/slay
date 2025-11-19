
public struct Toggle {
    public var text:Text
    public var image:Image?
    public var isOn:Bool

    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ text: Text,
        image: Image? = nil,
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

// MARK: View
extension Toggle: View {
}