
public struct Rectangle {
    package var _width:Int32
    package var _height:Int32

    public init() {
        _width = 0
        _height = 0
    }
    public init(width: Int32, height: Int32) {
        _width = width
        _height = height
    }
}

extension Rectangle {
    public mutating func frame(width: Int32, height: Int32) {
        _width = width
        _height = height
    }
}

// MARK: View
extension Rectangle: View {
    public var width: Int32 {
        _width
    }

    public var height: Int32 {
        _height
    }
}