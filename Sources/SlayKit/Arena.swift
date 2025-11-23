
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

        let hasFixedWidth = style.size.width != nil
        let hasFixedHeight = style.size.height != nil
        var targetWidth = Float(hasFixedWidth ? style.size.width! : available.x - marginX)
        var targetHeight = Float(hasFixedHeight ? style.size.height! : available.y - marginY)

        if let aspectRatio = style.aspectRatio {
            if !hasFixedWidth && hasFixedHeight {
                targetWidth = targetHeight * aspectRatio
            } else if hasFixedWidth && !hasFixedHeight {
                targetHeight = targetWidth / aspectRatio
            }
        }

        if node.children.isEmpty {
            let w = max(0, targetWidth - paddingX)
            let h = max(0, targetHeight - paddingY)
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
        let getCursor:(_ x: Float, _ y: Float) -> Float
        let getChildAvailX:(_ main: Float, _ cross: Float) -> Float
        let getChildAvailY:(_ main: Float, _ cross: Float) -> Float
        let getContentWidth:(Rect) -> Float
        let getContentHeight:(Rect) -> Float
        let mutateCursor:(_ xCursor: inout Float, _ yCursor: inout Float, _ amount: Float) -> Void
        let getFinalWidthPadding:(Style) -> Float
        let getFinalHeightPadding:(Style) -> Float
        
        if style.axis == .row {
            widthAvailable = targetWidth - paddingX
            heightAvailable = targetHeight - paddingY
            getChildWidth = { $0.size.width }
            getChildHeight = { $0.size.height }
            getCursor = { x, _ in x }
            getChildAvailX = { main, _ in main }
            getChildAvailY = { _, cross in cross }
            getContentWidth = { $0.w }
            getContentHeight = { $0.h }
            mutateCursor = { _, yCursor, amount in yCursor += amount }
            getFinalWidthPadding = { $0.padding.right }
            getFinalHeightPadding = { $0.padding.bottom }
        } else {
            widthAvailable = targetHeight - paddingY
            heightAvailable = targetWidth - paddingX
            getChildWidth = { $0.size.height }
            getChildHeight = { $0.size.width }
            getCursor = { _, y in y }
            getChildAvailX = { _, cross in cross }
            getChildAvailY = { main, _ in main }
            getContentWidth = { $0.h }
            getContentHeight = { $0.w }
            mutateCursor = { xCursor, _, amount in xCursor += amount }
            getFinalWidthPadding = { $0.padding.bottom }
            getFinalHeightPadding = { $0.padding.right }
        }

        // TODO: fix | final dimensions is miscalculated if we use nested children

        // Simple single-line or wrap lines
        var lines = [Line()]
        var current = Vec2(x: 0, y: 0)
        for child in node.children {
            let childStyle = nodes[child.raw].style
            let childHeight = getChildHeight(childStyle)
            let childWidth = getChildWidth(childStyle) ?? 0 // flex items initially 0
            if style.wrap && current.x + childWidth > widthAvailable && !lines.last!.items.isEmpty {
                lines.append(Line())
                current = Vec2(x: 0, y: 0)
            }
            lines[lines.count-1].items.append(child)
            current.x += childWidth + style.gap
            lines[lines.count-1].height = max(lines.last!.height, childHeight ?? 0)
        }

        var yCursor = style.padding.top
        var xCursor = style.padding.left
        var contentWidth:Float = 0
        var contentHeight:Float = 0

        for (lineIndex, line) in lines.enumerated() {
            var fixed:Float = 0
            var flexSum:Float = 0
            for child in line.items {
                let childStyle = nodes[child.raw].style
                if let fixedMain = getChildWidth(childStyle) {
                    fixed += Float(fixedMain)
                } else {
                    flexSum += childStyle.grow
                }
                if !lineIndex._isPaddedLast(line.items.count) {
                    fixed += style.gap
                }
            }
            let free = max(0, widthAvailable - fixed)
            var cursor = getCursor(xCursor, yCursor)
            for (lineItemIndex, child) in line.items.enumerated() {
                let childStyle = nodes[child.raw].style
                let childMain:Float
                if let fixedMain = getChildWidth(childStyle) {
                    childMain = fixedMain
                } else if flexSum > 0 {
                    childMain = free * (childStyle.grow / max(0.0001, flexSum))
                } else {
                    childMain = 0
                }
                let childCross = getChildHeight(childStyle) ?? line.height
                let childAvail = Vec2(
                    x: getChildAvailX(childMain, childCross),
                    y: getChildAvailY(childMain, childCross)
                )
                let childOrigin = Vec2(
                    x: origin.x + style.margin.left + getCursor(cursor, xCursor),
                    y: origin.y + style.margin.top + getCursor(yCursor, cursor)
                )
                let laid = layoutNode(id: child, origin: childOrigin, available: childAvail)
                cursor += getContentWidth(laid) + (lineItemIndex == line.items.count-1 ? 0 : style.gap)
                contentWidth = max(contentWidth, cursor)
                contentHeight += getContentHeight(laid)
            }
            mutateCursor(&xCursor, &yCursor, line.height + style.gap)
        }

        let finalWidth:Float
        let finalHeight:Float
        if node.name == "root" {
            finalWidth = max(targetWidth, contentWidth + getFinalWidthPadding(style))
            finalHeight = max(targetHeight, contentHeight + getFinalHeightPadding(style))
        } else {
            finalWidth = min(targetWidth, contentWidth + getFinalWidthPadding(style))
            finalHeight = min(targetHeight, contentHeight + getFinalHeightPadding(style))
        }
        node.layout = Rect(
            x: origin.x + style.margin.left,
            y: origin.y + style.margin.top,
            w: finalWidth,
            h: finalHeight
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