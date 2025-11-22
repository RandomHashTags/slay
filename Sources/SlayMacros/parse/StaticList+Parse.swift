
import SlayKit
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticList {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol,
        fontAtlas: borrowing FontAtlas
    ) -> Self? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        var list = Self()
        if let array = f.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements {
            appendArray(context: context, array: array, fontAtlas: fontAtlas, into: &list.data)
        } else if let statements = f.trailingClosure?.statements {
            appendCodeBlockList(context: context, codeBlockList: statements, fontAtlas: fontAtlas, into: &list.data)
        } else {
            fatalError(f.debugDescription)
            return nil
        }
        for arg in f.arguments {
            switch arg.label?.text {
            case "backgroundColor":
                list.backgroundColor = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        return list
    }
}