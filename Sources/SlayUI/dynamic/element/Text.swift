
import SlayKit

public struct Text: View {
    public var text:String
    public var fontSize:Int

    public init(
        _ text: String,
        fontSize: Int = slayDefaultFontSize,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.fontSize = fontSize
    }

    public var body: some View {
        fatalError("tried to get the body of a `Text`") // TODO: fix
    }
}

// MARK: ExpressibleByStringLiteral
extension Text: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.text = value
        fontSize = slayDefaultFontSize
    }
}