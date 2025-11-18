
public struct NodeId: Sendable, Hashable {
    public let raw:Int

    public init(
        raw: Int
    ) {
        self.raw = raw
    }
}