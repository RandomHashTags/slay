
import SlayKit
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticText {
    public static func parse(
        context: some MacroExpansionContext,
        expr: FunctionCallExprSyntax,
        fontAtlas: borrowing FontAtlas
    ) -> Self? {
        guard let text = expr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments.description else {
            fatalError("StaticText parse failed;expr=\(expr.debugDescription)")
        }
        let (width, height) = fontAtlas.measure(text)
        var view = StaticText(text)
        view.frame._width = Int32(width)
        view.frame._height = Int32(height)
        view.backgroundColor = .rgba(255, 255, 255, 255)
        return view
    }
}