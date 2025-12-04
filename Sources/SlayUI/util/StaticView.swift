
public protocol StaticView: Sendable {
    /// Dimensions of the view.
    var frame: StaticRectangle { get set }

    var backgroundColor: Color? { get }
}