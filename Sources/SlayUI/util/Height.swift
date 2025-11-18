
public enum Height: Sendable {
    case grow
    case pixels(Int32)
}

extension Height: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int32) {
        self = .pixels(value)
    }
}