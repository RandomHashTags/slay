
public struct Glyph {
    public let codepoint:UInt32
    public let atlasX:Int
    public let atlasY:Int
    public let width:Int
    public let height:Int
    public let bearingX:Int
    public let bearingY:Int
    public let advance:Int
    
    public init(
        codepoint: UInt32,
        atlasX: Int,
        atlasY: Int,
        width: Int,
        height: Int,
        bearingX: Int,
        bearingY: Int,
        advance: Int
    ) {
        self.codepoint = codepoint
        self.atlasX = atlasX
        self.atlasY = atlasY
        self.width = width
        self.height = height
        self.bearingX = bearingX
        self.bearingY = bearingY
        self.advance = advance
    }
}