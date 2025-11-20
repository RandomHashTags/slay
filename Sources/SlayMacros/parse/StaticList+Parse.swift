
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticList {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        guard let array = f.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements else { return nil }
        var list = Self()
        for element in array {
            guard let view = ViewMacro.parseView(context: context, expr: element.expression) else { continue }
            switch view {
            case .staticHStack(let v): list.data.append(v)
            case .staticList(let v): list.data.append(v)
            case .staticRectangle(let v): list.data.append(v)
            case .staticVStack(let v): list.data.append(v)
            case .staticZStack(let v): list.data.append(v)
            default:
                break
            }
        }
        return list
    }
}