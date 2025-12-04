
import SlayKit
import SlayUI

final class LayoutEngine {

    let root:ViewNode

    init() {
        root = .init(
            type: .staticEmpty(.init()),
            children: [],
            name: "root",
        )
        root.style.padding = .init(left: 8, top: 8, right: 8, bottom: 8)
    }

    func setBody(_ body: ViewType) {
        root.children = [.init(type: body)]
    }
}

// MARK: Render commands
extension LayoutEngine {
    func renderCommands(
        fontAtlas: borrowing FontAtlas
    ) -> [(RenderCommand, ViewNode)] {
        var renderCommands = [(RenderCommand, ViewNode)]()
        let cmd = renderCommandFor(node: root, fontAtlas: fontAtlas)
        renderCommands.append((cmd, root))
        appendRenderCommands(
            for: root.children,
            fontAtlas: fontAtlas,
            renderCommands: &renderCommands
        )
        return renderCommands
    }

    private func appendRenderCommands(
        for children: [ViewNode],
        fontAtlas: borrowing FontAtlas,
        renderCommands: inout [(RenderCommand, ViewNode)]
    ) {
        for child in children {
            let cmd = renderCommandFor(
                node: child,
                fontAtlas: fontAtlas
            )
            renderCommands.append((cmd, child))
            appendRenderCommands(
                for: child.children,
                fontAtlas: fontAtlas,
                renderCommands: &renderCommands
            )
        }
    }
    private func renderCommandFor(
        node: ViewNode,
        fontAtlas: borrowing FontAtlas
    ) -> RenderCommand {
        let frame = node.frame
        /*guard let nodeBG = nodeBGs[nodeId.raw] else {
            // no color, no render
            return nil
        }*/
        let nodeBG = node.type.backgroundColor ?? Color.rgba(0, 0, 0, 0)
        let color = (
            Float(nodeBG.red) / 255,
            Float(nodeBG.green) / 255,
            Float(nodeBG.blue) / 255,
            Float(nodeBG.alpha) / 255
        )
        /*switch node.type {
        case .staticText(let staticText):
            let vertices = fontAtlas.vertices(for: staticText.text, x: frame.x, y: frame.y)
            return .textVertices(vertices: vertices, color: color)
        default:
            break
        }*/
        return .rect(
            frame: frame,
            radius: 0,
            color: color
        )
    }
}