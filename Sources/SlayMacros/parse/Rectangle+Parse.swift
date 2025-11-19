
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension Rectangle {
    public static func parse(
        context: some MacroExpansionContext,
        expr: FunctionCallExprSyntax
    ) -> Rectangle {
        var rect = Rectangle()
        for arg in expr.arguments {
            switch arg.label?.text {
            case "width":
                guard let text = arg.expression.as(IntegerLiteralExprSyntax.self)?.literal.text else { continue }
                guard let v = Int32(text) else { continue }
                rect._width = v
            case "height":
                guard let text = arg.expression.as(IntegerLiteralExprSyntax.self)?.literal.text else { continue }
                guard let v = Int32(text) else { continue }
                rect._height = v
            case "backgroundColor":
                rect.backgroundColor = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        return rect
    }
}