
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
        var settings = SlayMacroExpansionSettings()
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for arg in arguments {
                switch arg.label?.text {
                case "font":
                    break
                case "renderInvisibleItems":
                    settings.renderInvisibleItems = arg.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
                case "renderTextAsRectangles":
                    settings.renderTextAsRectangles = arg.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
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

            let allRenderCommands = engine.renderCommands(fontAtlas: fontAtlas, settings: settings)
            var visibleItemIndexes = Set<Int>()
            visibleItemIndexes.reserveCapacity(allRenderCommands.count)
            var members = MemberBlockItemListSyntax()
            for (index, (cmd, node)) in allRenderCommands.enumerated() {
                var leadingTrivia:Trivia
                if node.customName != nil {
                    leadingTrivia = "/* \(node.name)\n*/\n"
                } else {
                    leadingTrivia = "// \(node.name)\n"
                }
                if settings.renderInvisibleItems || cmd.color.3 > 0 { // alpha/opacity is greater than zero
                    visibleItemIndexes.insert(index)
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
            let renderCommands:[RenderCommand]
            var renderCommandReferences = [String]()
            if settings.renderInvisibleItems {
                renderCommands = allRenderCommands.enumerated().map({
                    renderCommandReferences.append("Self._\($0.offset)")
                    return $0.element.0
                })
            } else {
                renderCommands = allRenderCommands.enumerated().compactMap({
                    guard visibleItemIndexes.contains($0.offset) else { return nil }
                    renderCommandReferences.append("Self._\($0.offset)")
                    return $0.element.0
                })
            }
            let cmdsTypeSyntax = TypeSyntax(stringLiteral: "[\(renderCommandReferences.count) of RenderCommand]")
            members.append(.init(decl: VariableDeclSyntax.init(
                modifiers: [
                    .init(name: .keyword(.public)),
                    .init(name: .keyword(.static))
                ],
                .let,
                name: "renderCommands",
                type: .init(type: cmdsTypeSyntax),
                initializer: .init(value: ExprSyntax(stringLiteral: "[\(renderCommandReferences.joined(separator: ", "))]"))
            )))

            var renderCommandOffsetItems = CodeBlockItemListSyntax()
            renderCommandOffsetItems.append(.init(item: .stmt(.init(ReturnStmtSyntax(expression: ArrayExprSyntax(elements: .init(expressions: renderCommands.enumerated().map({
                let elementOffset = $0.element.offset
                var expr = ExprSyntax(stringLiteral: offset(
                    command: $0.element,
                    x: elementOffset.x == 0 ? "offsetX" : "\(elementOffset.x) + offsetX",
                    y: elementOffset.y == 0 ? "offsetY" : "\(elementOffset.y) + offsetY"
                ))
                expr.leadingTrivia = .newline
                return expr
            }))))))))

            members.append(.init(decl: FunctionDeclSyntax.init(
                modifiers: [
                    .init(name: .keyword(.public)),
                    .init(name: .keyword(.static))
                ],
                name: "renderCommandsWithOffset",
                signature: .init(
                    parameterClause: .init(parameters: [
                        .init(firstName: "offsetX", type: TypeSyntax("Float"), trailingComma: .commaToken()),
                        .init(firstName: "offsetY", type: TypeSyntax("Float"))
                    ]),
                    returnClause: .init(type: cmdsTypeSyntax)
                ),
                body: .init(statements: renderCommandOffsetItems)
            )))

            let staticStruct = StructDeclSyntax(
                leadingTrivia: "// MARK: \(width)x\(height)\n",
                modifiers: [
                    .init(name: .keyword(.public))
                ],
                name: "Static_\(raw: width)x\(raw: height)",
                memberBlock: .init(members: members)
            )
            decls.append(.init(staticStruct))
        }
        return decls
    }

    private static func offset(command: RenderCommand, x: String, y: String) -> String {
        switch command {
        case .rect(let frame, let radius, let color):
            return ".rect(frame: \(offset(frame: frame, x: x, y: y)), radius: \(radius), color: \(color))"
        case .text(let text, _, _, let color):
            return ".text(text: \"\"\"\n\(text)\n\"\"\", x: \(x), y: \(y), color: \(color))"
        case .textVertices(let vertices, let color):
            var newVertices = ""
            newVertices.reserveCapacity(vertices.count * 18) // X.X, Y.Y, 0.0, 0.0
            var i:UInt8 = 0
            loop: for vert in vertices {
                newVertices.append(", ")
                switch i {
                case 0: // x
                    newVertices.append(vert == 0 ? "offsetX" : "\(vert) + offsetX")
                case 1: // y
                    newVertices.append(vert == 0 ? "offsetY" : "\(vert) + offsetY")
                case 2:
                    newVertices.append("\(vert)")
                case 3:
                    newVertices.append("\(vert)")
                    i = 0
                    continue loop
                default:
                    break
                }
                i += 1
            }
            newVertices.removeFirst(2)
            return ".textVertices(vertices: [\(newVertices)], color: \(color))"
        }
    }
    private static func offset(frame: Rect, x: String, y: String) -> String {
        return "Rect(x: \(x), y: \(y), w: \(frame.w), h: \(frame.h))"
    }
}