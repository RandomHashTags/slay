
//import Freetype2

public struct StaticText: StaticView {
    public var text:String
    public var fontSize:Int32
    public var frame:StaticRectangle
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

// MARK: ExpressibleByStringLiteral
extension StaticText: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.text = value
        fontSize = 16
        frame = .init(width: nil, height: nil)
        backgroundColor = nil
    }
}