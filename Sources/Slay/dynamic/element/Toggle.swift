
public struct Toggle {
    public var text:Text
    public var image:Image?
    public var isOn:Bool

    public init(
        _ text: Text,
        image: Image? = nil,
        isOn: Bool
    ) {
        self.text = text
        self.image = image
        self.isOn = isOn
    }
}

// MARK: View
extension Toggle: View {
    public var width: Int32 {
        text.width + (image?.width ?? 0) // TODO: what should the toggle switch width be?
    }

    public var height: Int32 {
        max(text.height, image?.height ?? 0) // TODO: what should the toggle switch height be?
    }
}