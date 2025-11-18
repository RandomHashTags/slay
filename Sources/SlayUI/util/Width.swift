
public enum Width: Sendable {
    case grow
    case pixels(Int32)
}

extension Width: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int32) {
        self = .pixels(value)
    }
}