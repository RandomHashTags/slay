
public final class Arena: @unchecked Sendable {
    package var nodes = [Node]()

    public init() {
    }

    @discardableResult
    public func create(
        _ style: Style,
        name: String
    ) -> NodeId {
        let id = NodeId(raw: nodes.count)
        nodes.append(Node(style: style, name: name))
        return id
    }

    public func setChildren(_ parent: NodeId, _ children: [NodeId]) {
        nodes[parent.raw].children = children
    }

    public func updateStyle(_ id: NodeId, _ style: Style) {
        nodes[id.raw].style = style
    }

    public func style(of id: NodeId) -> Style {
        nodes[id.raw].style
    }

    public func layout(of id: NodeId) -> Rect {
        nodes[id.raw].layout
    }
    public func layout(of id: Int) -> Rect {
        nodes[id].layout
    }
}

// MARK: Node
extension Arena {
    public final class Node: @unchecked Sendable {
        public var style:Style
        public var children:[NodeId]
        public var layout:Rect
        public var measured:Bool
        public var name:String

        public init(
            style: Style,
            children: [NodeId] = [],
            layout: Rect = Rect(x: 0, y: 0, w: 0, h: 0),
            measured: Bool = false,
            name: String
        ) {
            self.style = style
            self.children = children
            self.layout = layout
            self.measured = measured
            self.name = name
        }
    }
}

// MARK: Compute
extension Arena {
    public func compute(root: NodeId, available: Vec2) {
        _ = layoutNode(
            id: root,
            origin: Vec2(x: 0, y: 0),
            available: available
        )
    }
}

// MARK: Layout
extension Arena {
    /// - Returns: The computed layout for the node.
    @discardableResult
    private func layoutNode(
        id: NodeId,
        origin: Vec2,
        available: Vec2
    ) -> Rect {
        let node = nodes[id.raw]
        let style = node.style
        let paddingX = style.padding.left + style.padding.right
        let paddingY = style.padding.top + style.padding.bottom
        let marginX = style.margin.left + style.margin.right
        let marginY = style.margin.top + style.margin.bottom

        let hasFixedW = style.size.width != nil
        let hasFixedH = style.size.height != nil
        var targetW = Float(hasFixedW ? style.size.width! : available.x - marginX)
        var targetH = Float(hasFixedH ? style.size.height! : available.y - marginY)

        if let aspectRatio = style.aspectRatio {
            if !hasFixedW && hasFixedH {
                targetW = targetH * aspectRatio
            } else if hasFixedW && !hasFixedH {
                targetH = targetW / aspectRatio
            }
        }

        if node.children.isEmpty {
            let w = max(0, targetW - paddingX)
            let h = max(0, targetH - paddingY)
            node.layout = Rect(
                x: origin.x + style.margin.left,
                y: origin.y + style.margin.top,
                w: w + paddingX,
                h: h + paddingY
            )
            nodes[id.raw] = node
            return node.layout
        }

        // Flex layout (simplified): collect fixed-size and flex items, no min/max for brevity.
        let widthAvailable:Float
        let heightAvailable:Float
        let getChildWidth:(Style) -> Float?
        let getChildHeight:(Style) -> Float?
        let getOffset:(_ x: Float, _ y: Float) -> Float
        let getChildAvailX:(_ main: Float, _ cross: Float) -> Float
        let getChildAvailY:(_ main: Float, _ cross: Float) -> Float
        let getLaidOffset:(Rect) -> Float
        let mutateOffset:(_ xCursor: inout Float, _ yCursor: inout Float, _ amount: Float) -> Void
        let getContentHeight:(Rect) -> Float
        let getFinalWidthPadding:(Style) -> Float
        let getFinalHeightPadding:(Style) -> Float
        
        if style.axis == .horizontal {
            widthAvailable = targetW - paddingX
            heightAvailable = targetH - paddingY
            getChildWidth = { $0.size.width }
            getChildHeight = { $0.size.height }
            getOffset = { x, _ in x }
            getChildAvailX = { width, _ in width }
            getChildAvailY = { _, height in height }
            getLaidOffset = { $0.w }
            mutateOffset = { _, yOffset, amount in yOffset += amount }
            getContentHeight = { $0.h }
            getFinalWidthPadding = { $0.padding.right }
            getFinalHeightPadding = { $0.padding.bottom }
        } else {
            widthAvailable = targetH - paddingY
            heightAvailable = targetW - paddingX
            getChildWidth = { $0.size.height }
            getChildHeight = { $0.size.width }
            getOffset = { _, y in y }
            getChildAvailX = { _, height in height }
            getChildAvailY = { width, _ in width }
            getLaidOffset = { $0.h }
            mutateOffset = { xOffset, _, amount in xOffset += amount }
            getContentHeight = { $0.w }
            getFinalWidthPadding = { $0.padding.bottom }
            getFinalHeightPadding = { $0.padding.right }
        }

        // Simple single-line or wrap lines
        var lines = [Line()]
        var current = Vec2(x: 0, y: 0)
        for child in node.children {
            let childStyle = nodes[child.raw].style
            let childCrossFixed = getChildHeight(childStyle)
            let mainSize = getChildWidth(childStyle) ?? 0 // flex items initially 0
            if style.wrap && current.x + mainSize > widthAvailable && !lines.last!.items.isEmpty {
                lines.append(Line())
                current = Vec2(x: 0, y: 0)
            }
            lines[lines.count-1].items.append(child)
            current.x += mainSize + style.gap
            lines[lines.count-1].height = max(lines.last!.height, childCrossFixed ?? 0)
        }

        var yOffset = style.padding.top
        var xOffset = style.padding.left
        var contentWidth:Float = 0
        var contentHeight:Float = 0

        for (lineIndex, line) in lines.enumerated() {
            var fixed:Float = 0
            var flexSum:Float = 0
            for child in line.items {
                let childStyle = nodes[child.raw].style
                if let fixedWidth = getChildWidth(childStyle) {
                    fixed += Float(fixedWidth)
                } else {
                    flexSum += childStyle.grow
                }
                if lineIndex != line.items.count-1 { // is not last
                    fixed += style.gap
                }
            }
            let free = max(0, widthAvailable - fixed)
            var offset = getOffset(xOffset, yOffset)
            for (lineItemIndex, child) in line.items.enumerated() {
                let childStyle = nodes[child.raw].style
                let childWidth:Float
                if let fixedWidth = getChildWidth(childStyle) {
                    childWidth = fixedWidth
                } else if flexSum > 0 {
                    childWidth = free * (childStyle.grow / max(0.0001, flexSum))
                } else {
                    childWidth = 0
                }
                let childHeight = getChildHeight(childStyle) ?? line.height
                let childAvail = Vec2(
                    x: getChildAvailX(childWidth, childHeight),
                    y: getChildAvailY(childWidth, childHeight)
                )
                let childOrigin = Vec2(
                    x: origin.x + style.margin.left + getOffset(offset, xOffset),
                    y: origin.y + style.margin.top + getOffset(yOffset, offset)
                )
                let frame = layoutNode(id: child, origin: childOrigin, available: childAvail)
                offset += getLaidOffset(frame) + (lineItemIndex == line.items.count-1 ? 0 : style.gap)
                contentWidth = max(contentWidth, offset)
                contentHeight += getContentHeight(frame)
            }
            mutateOffset(&xOffset, &yOffset, line.height + style.gap)
        }

        let finalW = max(targetW, contentWidth + getFinalWidthPadding(style))
        let finalH = max(targetH, contentHeight + getFinalHeightPadding(style))
        node.layout = Rect(
            x: origin.x + style.margin.left,
            y: origin.y + style.margin.top,
            w: finalW,
            h: finalH
        )
        nodes[id.raw] = node
        return node.layout
    }
}

// MARK: Line
extension Arena {
    struct Line {
        var items  = [NodeId]()
        var height:Float = 0
        var width:Float = 0
    }
}