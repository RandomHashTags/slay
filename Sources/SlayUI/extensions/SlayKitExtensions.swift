
import FoundationEssentials
import SlayKit

extension Arena {
    @discardableResult
    package func create(
        _ view: some StaticView,
        name: String? = nil,
        axis: Axis = .vertical
    ) -> NodeId {
        var count = nodes.count
        return create(view, name: name, axis: axis, count: &count)
    }
    @discardableResult
    package func create(
        _ view: some StaticView,
        name: String? = nil,
        axis: Axis,
        gap: Float = 0,
        count: inout Int
    ) -> NodeId {
        let parentId = NodeId(raw: count)
        count += 1

        let name = name ?? UUID().uuidString
        let node = Node(
            style: view.style(axis: axis, gap: gap),
            name: name
        )
        nodes.append(node)

        if let list = view as? StaticList {
            node.style.axis = .vertical
            appendChildren(node: node, childViews: list.data, name: name, axis: .vertical, gap: 8, count: &count)
        } else if let stack = view as? StaticHStack {
            node.style.axis = .horizontal
            appendChildren(node: node, childViews: stack.data, name: name, axis: .horizontal, gap: 0, count: &count)
        } else if let stack = view as? StaticVStack {
            node.style.axis = .vertical
            appendChildren(node: node, childViews: stack.data, name: name, axis: .vertical, gap: 0, count: &count)
        } else if let stack = view as? StaticZStack {
            node.style.axis = .vertical
            appendChildren(node: node, childViews: stack.data, name: name, axis: .vertical, gap: 0, count: &count)
        }
        return parentId
    }
    private func appendChildren(
        node: Node,
        childViews: [any StaticView],
        name: String,
        axis: Axis,
        gap: Float,
        count: inout Int
    ) {
        var childIndex = 0
        for child in childViews {
            let childId = NodeId(raw: count)
            let childName = name + "Child\(childIndex)"
            let childNode = Node(
                style: child.style(axis: axis, gap: gap),
                name: childName
            )
            nodes.append(childNode)
            count += 1
            if let list = child as? StaticList {
                var i = 0
                for c in list.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", axis: .vertical, gap: 8, count: &count))
                    i += 1
                }
            } else if let stack = child as? StaticHStack {
                var i = 0
                for c in stack.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", axis: .horizontal, gap: 8, count: &count))
                    i += 1
                }
            } else if let stack = child as? StaticVStack {
                var i = 0
                for c in stack.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", axis: .vertical, gap: 8, count: &count))
                    i += 1
                }
            } else if let stack = child as? StaticZStack {
                var i = 0
                for c in stack.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", axis: .vertical, count: &count))
                    i += 1
                }
            }
            node.children.append(childId)
            childIndex += 1
        }
    }
}

// MARK: Style
extension StaticView {
    package func style(
        axis: Axis,
        gap: Float
    ) -> Style {
        var s = Style(
            axis: axis,
            gap: gap
        )
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