
/// Slay view settings during macro expansion.
public struct SlayMacroExpansionSettings {
    /// Whether or not to render content with their color alpha/opacity <= 0.
    public var renderInvisibleItems:Bool

    /// Whether or not to render static text as rectangles instead of raw text vertices.
    public var renderTextAsRectangles:Bool

    public init(
        renderInvisibleItems: Bool = false,
        renderTextAsRectangles: Bool = false
    ) {
        self.renderInvisibleItems = renderInvisibleItems
        self.renderTextAsRectangles = renderTextAsRectangles
    }
}