
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
            var renderedCommandIndexes = Set<Int>()
            renderedCommandIndexes.reserveCapacity(renderCommands.count)
            var members = MemberBlockItemListSyntax()
            for (index, (cmd, node)) in renderCommands.enumerated() {
                var leadingTrivia:Trivia
                if node.customName != nil {
                    leadingTrivia = "/* \(node.name)\n*/\n"
                } else {
                    leadingTrivia = "// \(node.name)\n"
                }
                if cmd.color.3 > 0 { // alpha/opacity is greater than zero
                    renderedCommandIndexes.insert(index)
                } else {
                    leadingTrivia += "//"
                }
                let variableDecl = VariableDeclSyntax(
                    leadingTrivia: leadingTrivia,
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
            let cmds:[String] = (0..<renderCommands.count).compactMap({
                guard renderedCommandIndexes.contains($0) else { return nil }
                return "Self._\($0)"
            })
            members.append(.init(decl: VariableDeclSyntax.init(
                modifiers: [
                    .init(name: .keyword(.static))
                ],
                .let,
                name: "renderCommands",
                type: .init(type: TypeSyntax(stringLiteral: "[\(cmds.count) of RenderCommand]")),
                initializer: .init(value: ExprSyntax(stringLiteral: "[\(cmds.joined(separator: ", "))]"))
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