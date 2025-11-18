
public struct Spacer {
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        backgroundColor: Color? = nil
    ) {
        frame = .init(width: 0, height: 0) // TODO: fix
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Spacer: View {
}