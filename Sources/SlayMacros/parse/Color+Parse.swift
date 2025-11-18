
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension Color {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Color? {
        if let f = expr.as(FunctionCallExprSyntax.self) {
            if let m = f.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.text {
                switch m {
                case "rgba":
                    guard f.arguments.count == 4 else { fatalError(expr.debugDescription) }
                    guard let red = parseInt(f.arguments[f.arguments.index(at: 0)].expression) else { return nil }
                    guard let green = parseInt(f.arguments[f.arguments.index(at: 1)].expression) else { return nil }
                    guard let blue = parseInt(f.arguments[f.arguments.index(at: 2)].expression) else { return nil }
                    guard let alpha = parseInt(f.arguments[f.arguments.index(at: 3)].expression) else { return nil }
                    return .rgba(red, green, blue, alpha)
                default:
                    break
                }
            }
        }
        fatalError(expr.debugDescription)
        // TODO: support
        return nil
    }

    private static func parseInt(_ expr: ExprSyntax) -> UInt8? {
        guard let t = expr.as(IntegerLiteralExprSyntax.self)?.literal.text else { return nil }
        return UInt8(t)
    }
}