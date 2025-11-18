
public struct Image {
    public var path:String

    public init(path: String) {
        self.path = path
    }
}

// MARK: Layoutable
extension Image: Layoutable {
    public var width: Int32 {
        0 // TODO: fix
    }

    public var height: Int32 {
        0 // TODO: fix
    }
}