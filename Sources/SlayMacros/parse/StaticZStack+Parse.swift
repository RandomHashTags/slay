
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticZStack {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        guard let array = f.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements else { return nil }
        var stack = Self()
        for element in array {
            guard let view = ViewMacro.parseView(context: context, expr: element.expression) else { continue }
            switch view {
            case .staticHStack(let v): stack.data.append(v)
            case .staticList(let v): stack.data.append(v)
            case .staticRectangle(let v): stack.data.append(v)
            case .staticVStack(let v): stack.data.append(v)
            case .staticZStack(let v): stack.data.append(v)
            default:
                break
            }
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