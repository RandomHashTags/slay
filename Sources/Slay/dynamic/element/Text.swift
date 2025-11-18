
public struct Text {
    public var text:String
    public var fontSize:Int32

    public init(
        _ text: String,
        fontSize: Int32 = 16
    ) {
        self.text = text
        self.fontSize = fontSize
    }
}

// MARK: View
extension Text: View {
    public var width: Int32 {
        0 // TODO: fix
    }

    public var height: Int32 {
        0 // TODO: fix
    }
}

// MARK: ExpressibleByStringLiteral
extension Text: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.text = value
        fontSize = 16
    }
}