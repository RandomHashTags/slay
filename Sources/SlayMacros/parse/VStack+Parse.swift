
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension VStack {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> VStack? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        guard let array = f.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements else { return nil }
        var stack = VStack()
        for element in array {
            guard let view = ViewMacro.parseView(context: context, expr: element.expression) else { continue }
            switch view {
            case .hstack(let v): stack.data.append(v)
            case .list(let v): stack.data.append(v)
            case .rectangle(let v): stack.data.append(v)
            case .vstack(let v): stack.data.append(v)
            case .zstack(let v): stack.data.append(v)
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