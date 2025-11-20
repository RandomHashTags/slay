
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
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for arg in arguments {
                switch arg.label?.text {
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
                        body = parseView(context: context, expr: funcExpr)
                    default:
                        break
                    }
                }
            }
        }

        let arena = Arena()
        let root = arena.create(
            Style(
                axis: .row,
                padding: Insets(left: 8, top: 8, right: 8, bottom: 8)
            ),
            name: "root"
        )
        var nodeBGs = [Color?]()
        nodeBGs.append(nil) // root node color
        if let body {
            arena.setChildren(root, [appendNode(arena: arena, view: body, nodeBGs: &nodeBGs)])
        }

        var decls = [DeclSyntax]()
        for (width, height) in supportedStaticDimensions {
            arena.compute(root: root, available: .init(x: Float(width), y: Float(height)))

            var renderCommands = [RenderCommand]()
            var members = MemberBlockItemListSyntax()
            let cmd = renderCommandFor(arena: arena, nodeBGs: nodeBGs, nodeId: root)
            renderCommands.append(cmd)
            appendRenderCommands(
                for: arena.nodes[root.raw].children,
                arena: arena,
                nodeBGs: nodeBGs,
                renderCommands: &renderCommands
            )
            for (index, cmd) in renderCommands.enumerated() {
                let node = arena.nodes[index]
                let variableDecl = VariableDeclSyntax(
                    leadingTrivia: "// \(node.name)\n",
                    modifiers: [
                        .init(name: .keyword(.static))
                    ],
                    .let,
                    name: "_\(raw: index)",
                    type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "RenderCommand")),
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

// MARK: Append render commands
extension ViewMacro {
    private static func appendRenderCommands(
        for children: [NodeId],
        arena: Arena,
        nodeBGs: [Color?],
        renderCommands: inout [RenderCommand]
    ) {
        for childId in children {
            let cmd = renderCommandFor(
                arena: arena,
                nodeBGs: nodeBGs,
                nodeId: childId
            )
            renderCommands.append(cmd)
            let subChildren = arena.nodes[childId.raw].children
            appendRenderCommands(
                for: subChildren,
                arena: arena,
                nodeBGs: nodeBGs,
                renderCommands: &renderCommands
            )
        }
    }
    private static func renderCommandFor(
        arena: Arena,
        nodeBGs: [Color?],
        nodeId: NodeId
    ) -> RenderCommand {
        let frame = arena.layout(of: nodeId)
        /*guard let nodeBG = nodeBGs[nodeId.raw] else { // we have the -1 because the root node is present
            // no color, no render
            return nil
        }*/
        let nodeBG = nodeBGs[nodeId.raw] ?? Color.rgba(0, 0, 0, 0)
        return RenderCommand.rect(
            frame: frame,
            radius: 0,
            bg: (nodeBG.red, nodeBG.green, nodeBG.blue, nodeBG.alpha)
        )
    }
}

// MARK: Append node
extension ViewMacro {
    static func appendNode(
        arena: Arena,
        view: ViewType,
        nodeBGs: inout [Color?]
    ) -> NodeId {
        switch view {
        case .staticList(let v):
            let id = arena.create(v)
            nodeBGs.append(v.backgroundColor)
            for d in v.data {
                nodeBGs.append(d.backgroundColor)
            }
            return id

        case .staticHStack(let v):
            let id = arena.create(v)
            nodeBGs.append(v.backgroundColor)
            for d in v.data {
                nodeBGs.append(d.backgroundColor)
            }
            return id
        case .staticVStack(let v):
            let id = arena.create(v)
            nodeBGs.append(v.backgroundColor)
            for d in v.data {
                nodeBGs.append(d.backgroundColor)
            }
            return id
        case .staticZStack(let v):
            let id = arena.create(v)
            nodeBGs.append(v.backgroundColor)
            for d in v.data {
                nodeBGs.append(d.backgroundColor)
            }
            return id

        case .staticRectangle(let v):
            let id = arena.create(v)
            nodeBGs.append(v.backgroundColor)
            return id
        default:
            fatalError("broken")
        }
    }
}

// MARK: StaticViewType
extension ViewMacro {
    enum ViewType {
        case staticHStack(StaticHStack)
        case staticList(StaticList)
        case staticRectangle(StaticRectangle)
        case staticVStack(StaticVStack)
        case staticZStack(StaticZStack)
        case custom(String)
    }
}

// MARK: Parse View
extension ViewMacro {
    static func parseView(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> ViewType? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        return parseView(context: context, expr: f)
    }
    static func parseView(
        context: some MacroExpansionContext,
        expr: FunctionCallExprSyntax
    ) -> ViewType? {
        switch expr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
        case "StaticButton", "Button": return nil
        case "StaticList", "List":
            guard let v = StaticList.parse(context: context, expr: expr) else { return nil }
            return .staticList(v)

        case "StaticHStack", "HStack":
            guard let v = StaticHStack.parse(context: context, expr: expr) else { return nil }
            return .staticHStack(v)
        case "StaticVStack", "VStack":
            guard let v = StaticVStack.parse(context: context, expr: expr) else { return nil }
            return .staticVStack(v)
        case "StaticZStack", "ZStack":
            guard let v = StaticZStack.parse(context: context, expr: expr) else { return nil }
            return .staticZStack(v)

        case "StaticCircle", "Circle": return nil
        case "StaticRectangle", "Rectangle":
            return .staticRectangle(.parse(context: context, expr: expr))
        default:
            return nil
        }
    }
}