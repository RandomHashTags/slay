
import SlayKit
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

extension ViewType {
    static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol,
        fontAtlas: borrowing FontAtlas
    ) -> ViewType? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        return parse(context: context, expr: f, fontAtlas: fontAtlas)
    }
    static func parse(
        context: some MacroExpansionContext,
        expr: FunctionCallExprSyntax,
        fontAtlas: borrowing FontAtlas
    ) -> ViewType? {
        switch expr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
        case "StaticButton", "Button": return nil
        case "StaticList", "List":
            guard let v = StaticList.parse(context: context, expr: expr, fontAtlas: fontAtlas) else { return nil }
            return .staticList(v)

        case "StaticHStack", "HStack":
            guard let v = StaticHStack.parse(context: context, expr: expr, fontAtlas: fontAtlas) else { return nil }
            return .staticHStack(v)
        case "StaticVStack", "VStack":
            guard let v = StaticVStack.parse(context: context, expr: expr, fontAtlas: fontAtlas) else { return nil }
            return .staticVStack(v)
        case "StaticZStack", "ZStack":
            guard let v = StaticZStack.parse(context: context, expr: expr, fontAtlas: fontAtlas) else { return nil }
            return .staticZStack(v)

        case "StaticCircle", "Circle": return nil
        case "StaticRectangle", "Rectangle":
            return .staticRectangle(.parse(context: context, expr: expr))

        case "StaticText", "Text":
            guard let v = StaticText.parse(context: context, expr: expr, fontAtlas: fontAtlas) else { return nil }
            return .staticText(v)

        default:
            return nil
        }
    }
}