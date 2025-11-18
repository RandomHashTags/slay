
public struct WindowSettings: Sendable, ~Copyable {

    public let title:String
    public let width:Int32
    public let height:Int32

    var _fps:UInt32
    var _fpsDelayMS:UInt32

    public let flagsRaw:UInt8

    public init(
        title: String = "Slay",
        width: Int32,
        height: Int32,
        fps: UInt32,

        allowsHighDPI: Bool = false,
        alwaysOnTop: Bool = false,
        fullscreen: Bool = false,
        resizable: Bool = true
    ) {
        self.title = title
        self.width = width
        self.height = height
        _fps = fps
        _fpsDelayMS = 1000 / fps

        flagsRaw =
            (allowsHighDPI ? Flags.allowsHighDPI.rawValue : 0)
            | (alwaysOnTop ? Flags.alwaysOnTop.rawValue : 0)
            | (fullscreen ? Flags.fullscreen.rawValue : 0)
            | (resizable ? Flags.resizable.rawValue : 0)
    }
}

// MARK: FPS manipulation
extension WindowSettings {
    public var fps: UInt32 {
        get { _fps }
        set {
            _fps = newValue
            _fpsDelayMS = 1000 / newValue
        }
    }

    public var fpsDelayMS: UInt32 {
        get { _fpsDelayMS }
        set {
            _fps = 1000 / newValue
            _fpsDelayMS = newValue
        }
    }
}

// MARK: Flags
extension WindowSettings {
    enum Flags: UInt8 {
        case alwaysOnTop    = 1
        case allowsHighDPI  = 2
        case fullscreen     = 4
        case resizable      = 8
    }
    func isFlag(_ flag: Flags) -> Bool { flagsRaw & flag.rawValue > 0 }
    public var allowsHighDPI: Bool { isFlag(.allowsHighDPI) }
    public var isAlwaysOnTop: Bool { isFlag(.alwaysOnTop) }
    public var isFullscreen: Bool { isFlag(.fullscreen) }
    public var isResizable: Bool { isFlag(.resizable) }
}