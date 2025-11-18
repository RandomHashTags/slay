
public struct Label {
    public var image:Image?
    public var text:Text

    public init(
        _ text: Text,
        image: Image?
    ) {
        self.text = text
        self.image = image
    }
}

// MARK: Layoutable
extension Label: Layoutable {
    public var width: Int32 {
        (image?.width ?? 0) + text.width
    }

    public var height: Int32 {
        min(image?.height ?? 0, text.height)
    }
}