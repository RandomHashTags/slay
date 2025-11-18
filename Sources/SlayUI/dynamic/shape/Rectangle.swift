
public struct Rectangle {
    public static let zero = Self(width: 0, height: 0)

    package var x:Int32 = 0
    package var y:Int32 = 0
    package var _width:Int32?
    package var _height:Int32?
    public var backgroundColor:Color?

    public init(
        backgroundColor: Color? = nil
    ) {
        _width = nil
        _height = nil
        self.backgroundColor = backgroundColor
    }
    public init(
        width: Int32? = nil,
        height: Int32? = nil,
        backgroundColor: Color? = nil
    ) {
        _width = width
        _height = height
        self.backgroundColor = backgroundColor
    }

    public init(
        x: Int32,
        y: Int32,
        width: Int32? = nil,
        height: Int32? = nil,
        backgroundColor: Color? = nil
    ) {
        self.x = x
        self.y = y
        self._width = width
        self._height = height
        self.backgroundColor = backgroundColor
    }
}

extension Rectangle {
    @discardableResult
    public mutating func frame(width: Int32, height: Int32) -> Self {
        _width = width
        _height = height
        return self
    }
}

// MARK: View
extension Rectangle: View {
    public var width: Int32 {
        _width ?? 0
    }
    public var height: Int32 {
        _height ?? 0
    }

    public var frame: Rectangle {
        get { self }
        set { self = newValue }
    }
}