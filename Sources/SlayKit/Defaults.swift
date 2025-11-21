
/// Measured in pixels.
public let slayDefaultFontSize = 14

public var slayDefaultFontAtlas: FontAtlas? {
    #if os(Linux)
    return .init(
        ttfPath: "/usr/share/fonts/Adwaita/AdwaitaMono-Regular.ttf",
        pixelSize: slayDefaultFontSize
    )
    #endif
    return nil
}