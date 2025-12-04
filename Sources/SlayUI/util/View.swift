
public protocol View: Sendable {

    /// The view type representing the body of this view.
    associatedtype Body:View

    /// The content of the view.
    var body: Body { get }
}