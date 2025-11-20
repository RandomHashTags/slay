
public struct Image: View {
    var data:ImageData

    public init(
        _ path: String
    ) {
        data = .systemPath(path)
    }
    public init(
        _ bytes: [UInt8]
    ) {
        data = .bytes(bytes)
    }

    public var body: some View {
        EmptyView() // TODO: fix
    }
}