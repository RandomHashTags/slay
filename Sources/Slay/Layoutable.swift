
public protocol Layoutable: Sendable {
    /// Number of horizontal pixels this layoutable uses.
    var width: Int32 { get }

    /// Number of vertical pixels this layoutable uses.
    var height: Int32 { get }
}