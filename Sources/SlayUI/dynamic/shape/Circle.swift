
public struct Circle {
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        backgroundColor: Color? = nil
    ) {
        frame = .zero // TODO: fix
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Circle: View {
}