
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
            case .list(let l):
                list.data.append(l)
            case .rectangle(let rect):
                list.data.append(rect)
            default:
                break
            }
        }
        return list
    }
}