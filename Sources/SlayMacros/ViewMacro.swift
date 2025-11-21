
import SlayKit
import SlayUI
import SwiftSyntax
import SwiftSyntaxMacros

struct ViewMacro: MemberMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var supportedStaticDimensions:[(width: Int32, height: Int32)] = slaySupportedStaticDimensions
        //fatalError(declaration.debugDescription)
        var fontAtlas = slayDefaultFontAtlas
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for arg in arguments {
                switch arg.label?.text {
                case "font":
                    break
                case "supportedStaticDimensions":
                    supportedStaticDimensions.removeAll(keepingCapacity: true)
                    guard let array = arg.expression.as(ArrayExprSyntax.self)?.elements else { continue }
                    for e in array {
                        guard let tuple = e.expression.as(TupleExprSyntax.self)?.elements, tuple.count == 2 else { continue }
                        guard let widthExpr = tuple.first!.expression.as(IntegerLiteralExprSyntax.self) else { continue }
                        guard let width = Int32(widthExpr.literal.text) else { continue }
                        guard let heightExpr = tuple.last!.expression.as(IntegerLiteralExprSyntax.self) else { continue }
                        guard let height = Int32(heightExpr.literal.text) else { continue }
                        supportedStaticDimensions.append((width, height))
                    }
                    break
                default:
                    break
                }
            }
        }
        var body:ViewType? = nil
        for member in declaration.memberBlock.members {
            if let v = member.decl.as(VariableDeclSyntax.self) {
                if let binding = v.bindings.first, let pattern = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                    switch pattern {
                    case "body":
                        guard case let .getter(items) = binding.accessorBlock?.accessors else { continue }
                        guard let funcExpr = items.first?.item.as(FunctionCallExprSyntax.self) else { continue }
                        guard fontAtlas != nil else { continue }
                        body = parseView(context: context, expr: funcExpr, fontAtlas: fontAtlas!)
                    default:
                        break
                    }
                }
            }
        }

        let engine = LayoutEngine()
        if let body {
            engine.setBody(body)
        }

        var decls = [DeclSyntax]()
        for (width, height) in supportedStaticDimensions {
            engine.compute(width: width, height: height)

            let renderCommands = engine.renderCommands()
            var members = MemberBlockItemListSyntax()
            for (index, cmd) in renderCommands.enumerated() {
                let node = engine.arena.nodes[index]
                let variableDecl = VariableDeclSyntax(
                    leadingTrivia: "// \(node.name)\n",
                    modifiers: [
                        .init(name: .keyword(.static))
                    ],
                    .let,
                    name: "_\(raw: index)",
                    type: .init(type: TypeSyntax(stringLiteral: "RenderCommand")),
                    initializer: .init(value: ExprSyntax(stringLiteral: ".\(cmd)"))
                )
                members.append(.init(decl: variableDecl))
            }

            members.append(.init(decl: VariableDeclSyntax.init(
                modifiers: [
                    .init(name: .keyword(.static))
                ],
                .let,
                name: "renderCommands",
                type: .init(type: TypeSyntax(stringLiteral: "[\(renderCommands.count) of RenderCommand]")),
                initializer: .init(value: ExprSyntax(stringLiteral: "[\((0..<renderCommands.count).map({ "Self._\($0)" }).joined(separator: ", "))]"))
            )))

            let staticStruct = StructDeclSyntax(
                leadingTrivia: "// MARK: \(width)x\(height)\n",
                name: "Static_\(raw: width)x\(raw: height)",
                memberBlock: .init(members: members)
            )
            decls.append(.init(staticStruct))
        }
        return decls
    }
}

// MARK: StaticViewType
extension ViewMacro {
    enum ViewType {
        case staticHStack(StaticHStack)
        case staticList(StaticList)
        case staticRectangle(StaticRectangle)
        case staticText(StaticText)
        case staticVStack(StaticVStack)
        case staticZStack(StaticZStack)
    }
}

// MARK: Parse View
extension ViewMacro {
    static func parseView(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol,
        fontAtlas: borrowing FontAtlas
    ) -> ViewType? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        return parseView(context: context, expr: f, fontAtlas: fontAtlas)
    }
    static func parseView(
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