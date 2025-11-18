
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
        let structDecl = declaration.as(StructDeclSyntax.self)!
        let name = structDecl.name.text
        var supportedStaticDimensions:[(width: Int32, height: Int32)] = [
            (1920, 1080),
            (1280, 720)
        ]
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
        var body:StaticView? = nil
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
        let root = arena.create(Style(axis: .row, padding: Insets(left: 8, top: 8, right: 8, bottom: 8), gap: 8), name: "root")
        var nodes = [NodeId]()
        var nodeBGs = [Color?]()
        if let body {
            appendNode(arena: arena, view: body, nodes: &nodes, nodeBGs: &nodeBGs)
            arena.setChildren(root, nodes)
        }

        var decls = [DeclSyntax]()
        for (width, height) in supportedStaticDimensions {
            arena.compute(root: root, available: .init(x: Float(width), y: Float(height)))

            var members = MemberBlockItemListSyntax()
            for (nodeIndex, node) in nodes.enumerated() {
                let frame = arena.layout(of: node)
                let nodeBG = nodeBGs[nodeIndex]
                let command = RenderCommand.rect(
                    frame: frame,
                    radius: 0,
                    bg: (nodeBG?.red ?? 0, nodeBG?.green ?? 0, nodeBG?.blue ?? 0, nodeBG?.alpha ?? 0)
                )
                let variableDecl = VariableDeclSyntax(
                    .var,
                    name: "_\(raw: node.raw)",
                    type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "RenderCommand")),
                    accessorBlock: .init(accessors: .getter(.init(stringLiteral: ".\(command)")))
                )
                members.append(.init(decl: variableDecl))
            }

            let staticStruct = StructDeclSyntax(
                name: "Static\(raw: name)_\(raw: width)x\(raw: height)",
                memberBlock: .init(members: members)
            )
            decls.append(.init(staticStruct))
        }
        return decls
    }
}

// MARK: Add nodes
extension ViewMacro {
    static func appendNode(
        arena: Arena,
        view: StaticView,
        nodes: inout [NodeId],
        nodeBGs: inout [Color?]
    ) {
        switch view {
        case .list(let l):
            for d in l.data {
                nodes.append(arena.create(d))
                nodeBGs.append(l.backgroundColor)
            }
        case .rectangle(let rect):
            nodes.append(arena.create(rect))
            nodeBGs.append(rect.backgroundColor)
        default:
            break
        }
    }
}

// MARK: StaticView
extension ViewMacro {
    enum StaticView {
        case list(List)
        case rectangle(Rectangle)
        case custom(String)
    }
}

// MARK: Parse View
extension ViewMacro {
    static func parseView(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> StaticView? {
        guard let f = expr.as(FunctionCallExprSyntax.self) else { return nil }
        return parseView(context: context, expr: f)
    }
    static func parseView(
        context: some MacroExpansionContext,
        expr: FunctionCallExprSyntax
    ) -> StaticView? {
        switch expr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
        case "Button": return nil
        case "List":
            guard let v = List.parse(context: context, expr: expr) else { return nil }
            return .list(v)

        case "HStack": return nil
        case "VStack": return nil
        case "ZStack": return nil

        case "Circle": return nil
        case "Rectangle": return .rectangle(.parse(context: context, expr: expr))
        default:
            return nil
        }
    }
}