
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension List {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> List? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        guard let array = f.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements else { return nil }
        var list = List()
        for element in array {
            guard let view = ViewMacro.parseView(context: context, expr: element.expression) else { continue }
            switch view {
            case .hstack(let v): list.data.append(v)
            case .list(let v): list.data.append(v)
            case .rectangle(let v): list.data.append(v)
            case .vstack(let v): list.data.append(v)
            case .zstack(let v): list.data.append(v)
            default:
                break
            }
        }
        return list
    }
}