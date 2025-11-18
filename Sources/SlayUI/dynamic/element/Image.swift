
public struct Image {
    var data:ImageData
    public var frame:Rectangle

    public init(_ path: String) {
        data = .systemPath(path)
        frame = .init(width: 0, height: 0) // TODO: fix
    }
    public init(_ bytes: [UInt8]) {
        data = .bytes(bytes)
        frame = .init(width: 0, height: 0) // TODO: fix
    }
}

// MARK: View
extension Image: View {
}