
public struct Style: Sendable {
    public var axis:Axis
    public var wrap:Bool
    public var justify:Justify
    public var align:Align
    public var grow:Float
    public var shrink:Float
    public var size:Size
    public var minSize:Size
    public var maxSize:Size
    public var margin:Insets
    public var padding:Insets
    public var gap:Float
    public var aspectRatio:Float? // width/height
    public var clip:Bool

    public init(
        axis: Axis = .column,
        wrap: Bool = false,
        justify: Justify = .start,
        align: Align = .start,
        grow: Float = 0,
        shrink: Float = 1,
        size: Size = .init(),
        minSize: Size = .init(),
        maxSize: Size = .init(),
        margin: Insets = .zero,
        padding: Insets = .zero,
        gap: Float = 0,
        aspectRatio: Float? = nil,
        clip: Bool = false
    ) {
        self.axis = axis
        self.wrap = wrap
        self.justify = justify
        self.align = align
        self.grow = grow
        self.shrink = shrink
        self.size = size
        self.minSize = minSize
        self.maxSize = maxSize
        self.margin = margin
        self.padding = padding
        self.gap = gap
        self.aspectRatio = aspectRatio
        self.clip = clip
    }
}