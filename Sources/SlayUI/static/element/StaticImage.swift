
public struct StaticImage: StaticView {
    var data:ImageData
    public var frame:StaticRectangle
    public var backgroundColor:Color?

    public init(
        _ path: String,
        backgroundColor: Color? = nil
    ) {
        data = .systemPath(path)
        frame = .init(width: 0, height: 0) // TODO: fix
        self.backgroundColor = backgroundColor
    }
    public init(
        _ bytes: [UInt8],
        backgroundColor: Color? = nil
    ) {
        data = .bytes(bytes)
        frame = .init(width: 0, height: 0) // TODO: fix
        self.backgroundColor = backgroundColor
    }
}