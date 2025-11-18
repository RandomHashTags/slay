
public protocol View: Sendable {
    /// Number of horizontal pixels this view uses.
    var width: Int32 { get }

    /// Number of vertical pixels this view uses.
    var height: Int32 { get }
}