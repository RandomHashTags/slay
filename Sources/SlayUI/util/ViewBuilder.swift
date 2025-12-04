
@resultBuilder
public struct ViewBuilder: Sendable {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<each Content: View>(_ content: repeat each Content) -> TupleView<(repeat each Content)> {
        .init(value: (repeat each content))
    }
}