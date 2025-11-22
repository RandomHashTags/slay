
import FoundationEssentials
import SlayKit

extension Arena {
    @discardableResult
    package func create(
        _ view: some StaticView,
        name: String? = nil
    ) -> NodeId {
        var count = nodes.count
        return create(view, name: name, count: &count)
    }
    @discardableResult
    package func create(
        _ view: some StaticView,
        name: String? = nil,
        count: inout Int
    ) -> NodeId {
        let parentId = NodeId(raw: count)
        count += 1

        let name = name ?? UUID().uuidString
        let node = Node(
            style: view.style(axis: .column, gap: 0),
            name: name
        )
        nodes.append(node)

        if let list = view as? StaticList {
            node.style.gap = 8
            appendChildren(node: node, childViews: list.data, name: name, axis: .column, gap: 0, count: &count)
        } else if let stack = view as? StaticHStack {
            node.style.axis = .row
            appendChildren(node: node, childViews: stack.data, name: name, axis: .row, gap: 0, count: &count)
        } else if let stack = view as? StaticVStack {
            appendChildren(node: node, childViews: stack.data, name: name, axis: .column, gap: 0, count: &count)
        } else if let stack = view as? StaticZStack {
            appendChildren(node: node, childViews: stack.data, name: name, axis: .column, gap: 0, count: &count)
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
                    childNode.children.append(create(c, name: childName + "Child\(i)", count: &count))
                    i += 1
                }
            } else if let stack = child as? StaticHStack {
                var i = 0
                for c in stack.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", count: &count))
                    i += 1
                }
            } else if let stack = child as? StaticVStack {
                var i = 0
                for c in stack.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", count: &count))
                    i += 1
                }
            } else if let stack = child as? StaticZStack {
                var i = 0
                for c in stack.data {
                    childNode.children.append(create(c, name: childName + "Child\(i)", count: &count))
                    i += 1
                }
            }
            node.children.append(childId)
            childIndex += 1
        }
    }
}

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