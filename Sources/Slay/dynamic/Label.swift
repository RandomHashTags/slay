
public struct Label {
    public var image:Image
    public var text:Text

    public init(_ text: Text, image: Image) {
        self.text = text
        self.image = image
    }
}

// MARK: Layoutable
extension Label: Layoutable {
    public var width: Int32 {
        image.width + text.width
    }

    public var height: Int32 {
        image.height + image.height
    }
}