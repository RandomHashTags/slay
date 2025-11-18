
public struct Spacer {
    public var frame:Rectangle

    public init() {
        frame = .init(width: 0, height: 0) // TODO: fix
    }
}

// MARK: View
extension Spacer: View {
}