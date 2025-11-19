
public struct Spacer {
    public var frame:Rectangle
    public var backgroundColor:Color?

    public init(
        backgroundColor: Color? = nil
    ) {
        frame = .init(width: nil, height: nil)
        self.backgroundColor = backgroundColor
    }
}

// MARK: View
extension Spacer: View {
}