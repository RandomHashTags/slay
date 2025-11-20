
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticHStack {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        var stack = Self()
        if let array = f.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements {
            appendArray(context: context, array: array, into: &stack.data)
        } else if let statements = f.trailingClosure?.statements {
            appendCodeBlockList(context: context, codeBlockList: statements, into: &stack.data)
        } else {
            fatalError(f.debugDescription)
            return nil
        }
        for arg in f.arguments {
            switch arg.label?.text {
            case "backgroundColor":
                stack.backgroundColor = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        return stack
    }
}