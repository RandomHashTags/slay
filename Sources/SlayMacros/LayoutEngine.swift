
import SlayKit
import SlayUI

final class LayoutEngine {

    let arena = Arena()
    let root:NodeId

    private var nodeBackgroundColors = [Color?]()
    private var nodeViews = [any StaticView]()

    init() {
        root = arena.create(
            Style(
                axis: .row,
                padding: Insets(left: 8, top: 8, right: 8, bottom: 8)
            ),
            name: "root"
        )
        nodeBackgroundColors.append(nil)
        nodeViews.append(EmptyView())
    }

    func setBody(_ body: ViewMacro.ViewType) {
        arena.setChildren(root, [appendNode(arena: arena, view: body)])
    }
}

// MARK: Compute
extension LayoutEngine {
    func compute(width: Int32, height: Int32) {
        arena.compute(root: root, available: .init(x: Float(width), y: Float(height)))
    }
}

// MARK: Render commands
extension LayoutEngine {
    func renderCommands() -> [RenderCommand] {
        var renderCommands = [RenderCommand]()
        let cmd = renderCommandFor(nodeId: root)
        renderCommands.append(cmd)
        appendRenderCommands(
            for: arena.nodes[root.raw].children,
            renderCommands: &renderCommands
        )
        return renderCommands
    }

    private func appendRenderCommands(
        for children: [NodeId],
        renderCommands: inout [RenderCommand]
    ) {
        for childId in children {
            let cmd = renderCommandFor(
                nodeId: childId
            )
            renderCommands.append(cmd)
            let subChildren = arena.nodes[childId.raw].children
            appendRenderCommands(
                for: subChildren,
                renderCommands: &renderCommands
            )
        }
    }
    private func renderCommandFor(
        nodeId: NodeId
    ) -> RenderCommand {
        let frame = arena.layout(of: nodeId)
        /*guard let nodeBG = nodeBGs[nodeId.raw] else {
            // no color, no render
            return nil
        }*/
        let nodeBG = nodeBackgroundColors[nodeId.raw] ?? Color.rgba(0, 0, 0, 0)
        let color = (
            Float(nodeBG.red) / 255,
            Float(nodeBG.green) / 255,
            Float(nodeBG.blue) / 255,
            Float(nodeBG.alpha) / 255
        )
        let targetView = nodeViews[nodeId.raw]
        if let staticText = targetView as? StaticText {
            return .text(text: staticText.text, x: frame.x, y: frame.y, color: color)
        }
        return RenderCommand.rect(
            frame: frame,
            radius: 0,
            color: color
        )
    }
}

// MARK: Append node
extension LayoutEngine {
    func appendNode(
        arena: Arena,
        view: ViewMacro.ViewType
    ) -> NodeId {
        switch view {
        case .staticList(let v):
            nodeViews.append(v)
            let id = arena.create(v)
            nodeBackgroundColors.append(v.backgroundColor)
            for d in v.data {
                nodeBackgroundColors.append(d.backgroundColor)
            }
            nodeViews.append(contentsOf: v.data)
            return id

        case .staticHStack(let v):
            nodeViews.append(v)
            let id = arena.create(v)
            nodeBackgroundColors.append(v.backgroundColor)
            for d in v.data {
                nodeBackgroundColors.append(d.backgroundColor)
            }
            nodeViews.append(contentsOf: v.data)
            return id
        case .staticVStack(let v):
            nodeViews.append(v)
            let id = arena.create(v)
            nodeBackgroundColors.append(v.backgroundColor)
            for d in v.data {
                nodeBackgroundColors.append(d.backgroundColor)
            }
            nodeViews.append(contentsOf: v.data)
            return id
        case .staticZStack(let v):
            nodeViews.append(v)
            let id = arena.create(v)
            nodeBackgroundColors.append(v.backgroundColor)
            for d in v.data {
                nodeBackgroundColors.append(d.backgroundColor)
            }
            nodeViews.append(contentsOf: v.data)
            return id

        case .staticRectangle(let v):
            nodeViews.append(v)
            let id = arena.create(v)
            nodeBackgroundColors.append(v.backgroundColor)
            return id

        case .staticText(let v):
            nodeViews.append(v)
            let id = arena.create(v)
            nodeBackgroundColors.append(v.backgroundColor)
            return id
        }
    }
}

// MARK: Misc
extension EmptyView: StaticView {
    public var frame: SlayUI.StaticRectangle {
        get { fatalError() }
        set { fatalError() }
    }

    public var backgroundColor: SlayUI.Color? {
        fatalError()
    }
}