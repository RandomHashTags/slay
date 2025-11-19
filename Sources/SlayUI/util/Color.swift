
public struct Color: Sendable {
    public var red:UInt8
    public var green:UInt8
    public var blue:UInt8
    public var alpha:UInt8

    public init() {
        red = 0
        green = 0
        blue = 0
        alpha = 0
    }

    init(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        alpha: UInt8,
    ) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

// MARK: Static funcs
extension Color {
    public static func rgba(
        _ red: UInt8,
        _ green: UInt8,
        _ blue: UInt8,
        _ alpha: UInt8
    ) -> Self {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: Static vars
extension Color {
    @inline(__always) public static var red: Self   { .rgba(255, 0, 0, 255) }
    @inline(__always) public static var green: Self { .rgba(0, 255, 0, 255) }
    @inline(__always) public static var blue: Self  { .rgba(0, 0, 255, 255) }
}