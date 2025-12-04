
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
        var fontAtlas:FontAtlas! = slayDefaultFontAtlas
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
        guard fontAtlas != nil else { return [] }
        var body:ViewType? = nil
        for member in declaration.memberBlock.members {
            if let v = member.decl.as(VariableDeclSyntax.self) {
                if let binding = v.bindings.first, let pattern = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                    switch pattern {
                    case "body":
                        guard case let .getter(items) = binding.accessorBlock?.accessors else { continue }
                        guard let funcExpr = items.first?.item.as(FunctionCallExprSyntax.self) else { continue }
                        body = ViewType.parse(context: context, expr: funcExpr, fontAtlas: fontAtlas)
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
            engine.layout(width: width, height: height)

            let renderCommands = engine.renderCommands(fontAtlas: fontAtlas)
            var members = MemberBlockItemListSyntax()
            for (index, (cmd, node)) in renderCommands.enumerated() {
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