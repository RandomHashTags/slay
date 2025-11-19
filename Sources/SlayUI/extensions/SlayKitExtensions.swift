
import FoundationEssentials
import SlayKit

extension Arena {
    @discardableResult
    package func create(
        _ view: some View,
        name: String? = nil
    ) -> NodeId {
        var count = nodes.count
        let parentId = NodeId(raw: count)
        count += 1

        let name = name ?? UUID().uuidString
        var axis = Axis.column
        var gap = Float(0) // TODO: fully support
        var children = [Node]()
        var childrenIds = [NodeId]()
        if let list = view as? List {
            gap = 8
            appendChildren(list.data, name: name, axis: axis, gap: gap, children: &children, childrenIds: &childrenIds, count: &count)
        } else if let stack = view as? HStack {
            axis = .row
            appendChildren(stack.data, name: name, axis: axis, gap: gap, children: &children, childrenIds: &childrenIds, count: &count)
        } else if let stack = view as? VStack {
            appendChildren(stack.data, name: name, axis: axis, gap: gap, children: &children, childrenIds: &childrenIds, count: &count)
        } else if let stack = view as? ZStack {
            appendChildren(stack.data, name: name, axis: axis, gap: gap, children: &children, childrenIds: &childrenIds, count: &count)
        }
        nodes.append(Node(style: view.style(axis: axis, gap: gap), children: childrenIds, name: name))
        nodes.append(contentsOf: children)
        return parentId
    }
    private func appendChildren(
        _ childViews: [any View],
        name: String,
        axis: Axis,
        gap: Float,
        children: inout [Node],
        childrenIds: inout [NodeId],
        count: inout Int
    ) {
        for child in childViews {
            let childId = NodeId(raw: count)
            children.append(Node(
                style: child.style(axis: axis, gap: gap),
                name: name + "Child\(children.count)"
            ))
            childrenIds.append(childId)
            count += 1
        }
    }
}

extension View {
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