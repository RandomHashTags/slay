
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
            /*renderCommandOffsetItems.append(.init(item: .decl(DeclSyntax("\nlet xOffset = SIMD64<Float>(repeating: offsetX)"))))
            renderCommandOffsetItems.append(.init(item: .decl(DeclSyntax("\nlet yOffset = SIMD64<Float>(repeating: offsetY)"))))
            var renderCommandSIMDXReferences = [String]()
            var renderCommandSIMDYReferences = [String]()

            var remainingRenderCommands = renderCommands.count
            if remainingRenderCommands >= 64 {
                let (amount, items) = try test(
                    offset: 0,
                    renderCommands: renderCommands,
                    renderCommandSIMDXReferences: &renderCommandSIMDXReferences,
                    renderCommandSIMDYReferences: &renderCommandSIMDYReferences,
                    SIMD64<Float>()
                )
                let remove = amount * 64
                remainingRenderCommands -= remove
                renderCommandOffsetItems.append(contentsOf: items)
            }
            if remainingRenderCommands >= 32 {
                let (amount, items) = try test(
                    offset: renderCommands.count - remainingRenderCommands,
                    renderCommands: renderCommands,
                    renderCommandSIMDXReferences: &renderCommandSIMDXReferences,
                    renderCommandSIMDYReferences: &renderCommandSIMDYReferences,
                    SIMD32<Float>()
                )
                let remove = amount * 32
                remainingRenderCommands -= remove
                renderCommandOffsetItems.append(contentsOf: items)
            }
            if remainingRenderCommands >= 16 {
                let (amount, items) = try test(
                    offset: renderCommands.count - remainingRenderCommands,
                    renderCommands: renderCommands,
                    renderCommandSIMDXReferences: &renderCommandSIMDXReferences,
                    renderCommandSIMDYReferences: &renderCommandSIMDYReferences,
                    SIMD16<Float>()
                )
                let remove = amount * 16
                remainingRenderCommands -= remove
                renderCommandOffsetItems.append(contentsOf: items)
            }
            if remainingRenderCommands >= 8 {
                let (amount, items) = try test(
                    offset: renderCommands.count - remainingRenderCommands,
                    renderCommands: renderCommands,
                    renderCommandSIMDXReferences: &renderCommandSIMDXReferences,
                    renderCommandSIMDYReferences: &renderCommandSIMDYReferences,
                    SIMD8<Float>()
                )
                let remove = amount * 8
                remainingRenderCommands -= remove
                renderCommandOffsetItems.append(contentsOf: items)
            }
            if remainingRenderCommands >= 4 {
                let (amount, items) = try test(
                    offset: renderCommands.count - remainingRenderCommands,
                    renderCommands: renderCommands,
                    renderCommandSIMDXReferences: &renderCommandSIMDXReferences,
                    renderCommandSIMDYReferences: &renderCommandSIMDYReferences,
                    SIMD4<Float>()
                )
                let remove = amount * 4
                remainingRenderCommands -= remove
                renderCommandOffsetItems.append(contentsOf: items)
            }
            if remainingRenderCommands >= 2 {
                let (amount, items) = try test(
                    offset: renderCommands.count - remainingRenderCommands,
                    renderCommands: renderCommands,
                    renderCommandSIMDXReferences: &renderCommandSIMDXReferences,
                    renderCommandSIMDYReferences: &renderCommandSIMDYReferences,
                    SIMD2<Float>()
                )
                let remove = amount * 2
                remainingRenderCommands -= remove
                renderCommandOffsetItems.append(contentsOf: items)
            }
            if remainingRenderCommands > 0 {
                // TODO: fix
                renderCommandSIMDXReferences.append("0")
                renderCommandSIMDYReferences.append("0")
            }*/

            renderCommandOffsetItems.append(.init(item: .stmt(.init(ReturnStmtSyntax(expression: ArrayExprSyntax(elements: .init(expressions: renderCommands.enumerated().map({
                let elementOffset = $0.element.offset
                var expr = ExprSyntax(stringLiteral: offset(
                    command: $0.element,
                    x: elementOffset.x == 0 ? "offsetX" : "\(elementOffset.x) + offsetX",
                    y: elementOffset.y == 0 ? "offsetY" : "\(elementOffset.y) + offsetY"
                    /*x: renderCommandSIMDXReferences[$0.offset],
                    y: renderCommandSIMDYReferences[$0.offset]*/
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

    private static func test<T: SIMD<Float>>(
        offset: Int,
        renderCommands: [RenderCommand],
        renderCommandSIMDXReferences: inout [String],
        renderCommandSIMDYReferences: inout [String],
        _ test: T
    ) throws -> (amount: Int, items: [CodeBlockItemSyntax]) {
        let (xSIMDs, ySIMDs):([T], [T]) = simds(offset: offset, for: renderCommands)
        var items = [CodeBlockItemSyntax]()

        let xItems = try xSIMDs.enumerated().map({
            let xSIMD = "xSIMD\(T.scalarCount)_\($0.offset)"
            var e = try VariableDeclSyntax("var \(raw: xSIMD) = \(raw: $0.element)")
            e.leadingTrivia = .newline
            for i in 0..<T.scalarCount {
                renderCommandSIMDXReferences.append("\(xSIMD)[\(i)]")
            }
            return CodeBlockItemSyntax(item: .decl(DeclSyntax(e)))
        })
        items.append(contentsOf: xItems)

        let yItems = try ySIMDs.enumerated().map({
            let ySIMD = "ySIMD\(T.scalarCount)_\($0.offset)"
            var e = try VariableDeclSyntax("var \(raw: ySIMD) = \(raw: $0.element)")
            e.leadingTrivia = .newline
            for i in 0..<T.scalarCount {
                renderCommandSIMDYReferences.append("\(ySIMD)[\(i)]")
            }
            return CodeBlockItemSyntax(item: .decl(DeclSyntax(e)))
        })
        items.append(contentsOf: yItems)

        let simdSuffix:String
        switch T.scalarCount {
        case 64: simdSuffix = ""
        case 32: simdSuffix = ".lowHalf"
        case 16: simdSuffix = ".lowHalf.lowHalf"
        case 8: simdSuffix = ".lowHalf.lowHalf.lowHalf"
        case 4: simdSuffix = ".lowHalf.lowHalf.lowHalf.lowHalf"
        case 2: simdSuffix = ".lowHalf.lowHalf.lowHalf.lowHalf.lowHalf"
        default: simdSuffix = ""
        }

        for i in 0..<xSIMDs.count {
            var xExpr = ExprSyntax("xSIMD\(raw: T.scalarCount)_\(raw: i) += xOffset\(raw: simdSuffix)")
            xExpr.leadingTrivia = .newline

            var yExpr = ExprSyntax("ySIMD\(raw: T.scalarCount)_\(raw: i) += yOffset\(raw: simdSuffix)")
            yExpr.leadingTrivia = .newline

            items.append(.init(item: .expr(xExpr)))
            items.append(.init(item: .expr(yExpr)))
        }
        return (xSIMDs.count, items)
    }

    private static func simds<T: SIMD<Float>>(
        offset: Int,
        for commands: [RenderCommand]
    ) -> (x: [T], y: [T]) {
        let numberOfSIMDs = (commands.count - offset) / T.scalarCount
        var xSIMDs = [T]()
        var ySIMDs = [T]()
        var commandIndex = offset
        var simdX = T()
        var simdY = T()
        for _ in 0..<numberOfSIMDs {
            for simdIndex in 0..<T.scalarCount {
                let offset = commands[commandIndex].offset
                simdX[simdIndex] = offset.x
                simdY[simdIndex] = offset.y
                commandIndex += 1
            }
            xSIMDs.append(simdX)
            ySIMDs.append(simdY)
            simdX = .zero
            simdY = .zero
        }
        return (xSIMDs, ySIMDs)
    }

    private static func offset(command: RenderCommand, x: String, y: String) -> String {
        switch command {
        case .rect(let frame, let radius, let color):
            return ".rect(frame: \(offset(frame: frame, x: x, y: y)), radius: \(radius), color: \(color))"
        case .text(let text, _, _, let color):
            return ".text(text: \"\"\"\n\(text)\n\"\"\", x: \(x), y: \(y), color: \(color))"
        case .textVertices(let vertices, let color):
            return ".textVertices(vertices: [], color: \(color))" // TODO: fix
        }
    }
    private static func offset(frame: Rect, x: String, y: String) -> String {
        return "Rect(x: \(x), y: \(y), w: \(frame.w), h: \(frame.h))"
    }
}