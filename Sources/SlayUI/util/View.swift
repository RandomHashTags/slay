
public protocol View: Sendable {
    /// Dimensions of the view.
    var frame: Rectangle { get set }
}