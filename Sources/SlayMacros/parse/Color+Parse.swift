
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension Color {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Color? {
        /*if let f = expr.as(FunctionCallExprSyntax.self) {
            fatalError(f.debugDescription)
        }*/
        // TODO: support
        return nil
    }
}