
public struct Image {
    var data:ImageData

    public init(_ path: String) {
        data = .systemPath(path)
    }
    public init(_ bytes: [UInt8]) {
        data = .bytes(bytes)
    }
}

// MARK: View
extension Image: View {
    public var width: Int32 {
        0 // TODO: fix
    }

    public var height: Int32 {
        0 // TODO: fix
    }
}