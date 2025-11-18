
import SlayKit

extension Arena {
    @discardableResult
    package func create(
        _ view: some View,
        name: String? = nil
    ) -> NodeId {
        let id = NodeId(raw: nodes.count)
        nodes.append(Node(style: view.style, name: name))
        return id
    }
}

extension View {
    package var style: Style {
        var s = Style()
        if let width = frame._width {
            s.size.width = Float(width)
        } else {
            s.grow = 1
        }
        if let height = frame._height {
            s.size.height = Float(height)
        } else {
            s.grow = 1
        }
        return s
    }
}