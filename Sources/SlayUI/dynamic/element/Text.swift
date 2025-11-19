
public struct Text {
    public var text:String
    public var fontSize:Int32
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        _ text: String,
        fontSize: Int32 = 16,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.fontSize = fontSize

        frame = .init(width: nil, height: nil)
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Text: View {
}

// MARK: ExpressibleByStringLiteral
extension Text: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.text = value
        fontSize = 16
        frame = .init(width: nil, height: nil)
        backgroundColor = nil
    }
}