
public final class Arena: @unchecked Sendable {
    package var nodes = [Node]()

    public init() {
    }

    @discardableResult
    public func create(
        _ style: Style = Style(),
        name: String? = nil
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
    public struct Node: Sendable {
        public var style:Style
        public var children:[NodeId]
        public var layout:Rect
        public var measured:Bool
        public var name:String?

        public init(
            style: Style,
            children: [NodeId] = [],
            layout: Rect = Rect(x: 0, y: 0, w: 0, h: 0),
            measured: Bool = false,
            name: String? = nil // debug
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
        var node = nodes[id.raw]
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
        let mainAvail:Float
        let crossAvail:Float
        let getChildMainFixed:(Style) -> Float?
        let getChildCrossFixed:(Style) -> Float?
        let getCursor:(_ x: Float, _ y: Float) -> Float
        let getChildAvailX:(_ main: Float, _ cross: Float) -> Float
        let getChildAvailY:(_ main: Float, _ cross: Float) -> Float
        let getLaidCursorFloat:(Rect) -> Float
        let mutateCursor:(_ xCursor: inout Float, _ yCursor: inout Float, _ amount: Float) -> Void
        let getContentCrossFloat:(Rect) -> Float
        let getFinalWidthPadding:(Style) -> Float
        let getFinalHeightPadding:(Style) -> Float
        
        if style.axis == .row {
            mainAvail = targetW - paddingX
            crossAvail = targetH - paddingY
            getChildMainFixed = { $0.size.width }
            getChildCrossFixed = { $0.size.height }
            getCursor = { x, _ in x }
            getChildAvailX = { main, _ in main }
            getChildAvailY = { _, cross in cross }
            getLaidCursorFloat = { $0.w }
            mutateCursor = { _, yCursor, amount in yCursor += amount }
            getContentCrossFloat = { $0.h }
            getFinalWidthPadding = { $0.padding.right }
            getFinalHeightPadding = { $0.padding.bottom }
        } else {
            mainAvail = targetH - paddingY
            crossAvail = targetW - paddingX
            getChildMainFixed = { $0.size.height }
            getChildCrossFixed = { $0.size.width }
            getCursor = { _, y in y }
            getChildAvailX = { _, cross in cross }
            getChildAvailY = { main, _ in main }
            getLaidCursorFloat = { $0.h }
            mutateCursor = { xCursor, _, amount in xCursor += amount }
            getContentCrossFloat = { $0.w }
            getFinalWidthPadding = { $0.padding.bottom }
            getFinalHeightPadding = { $0.padding.right }
        }

        // Simple single-line or wrap lines
        var lines = [Line()]
        var current = Vec2(x: 0, y: 0)
        for child in node.children {
            let childStyle = nodes[child.raw].style
            let childCrossFixed = getChildCrossFixed(childStyle)
            let mainSize = getChildMainFixed(childStyle) ?? 0 // flex items initially 0
            if style.wrap && current.x + mainSize > mainAvail && !lines.last!.items.isEmpty {
                lines.append(Line())
                current = Vec2(x: 0, y: 0)
            }
            lines[lines.count-1].items.append(child)
            current.x += mainSize + style.gap
            lines[lines.count-1].cross = max(lines.last!.cross, childCrossFixed ?? 0)
        }

        var yCursor = style.padding.top
        var xCursor = style.padding.left
        var contentMain: Float = 0
        var contentCross: Float = 0

        for (lineIndex, line) in lines.enumerated() {
            var fixed: Float = 0
            var flexSum: Float = 0
            for child in line.items {
                let childStyle = nodes[child.raw].style
                if let fixedMain = getChildMainFixed(childStyle) {
                    fixed += Float(fixedMain)
                } else {
                    flexSum += childStyle.grow
                }
                if !lineIndex._isPaddedLast(line.items.count) {
                    fixed += style.gap
                }
            }
            let free = max(0, mainAvail - fixed)
            var cursor = getCursor(xCursor, yCursor)
            for (lineItemIndex, child) in line.items.enumerated() {
                let childStyle = nodes[child.raw].style
                let childMain:Float
                if let fixedMain = getChildMainFixed(childStyle) {
                    childMain = fixedMain
                } else if flexSum > 0 {
                    childMain = free * (childStyle.grow / max(0.0001, flexSum))
                } else {
                    childMain = 0
                }
                let childCross = getChildCrossFixed(childStyle) ?? line.cross
                let childAvail = Vec2(
                    x: getChildAvailX(childMain, childCross),
                    y: getChildAvailY(childMain, childCross)
                )
                let childOrigin = Vec2(
                    x: origin.x + style.margin.left + getCursor(cursor, xCursor),
                    y: origin.y + style.margin.top + getCursor(yCursor, cursor)
                )
                let laid = layoutNode(id: child, origin: childOrigin, available: childAvail)
                cursor += getLaidCursorFloat(laid) + (lineItemIndex == line.items.count-1 ? 0 : style.gap)
                contentMain = max(contentMain, cursor)
                contentCross += getContentCrossFloat(laid)
            }
            mutateCursor(&xCursor, &yCursor, line.cross + style.gap)
        }

        let finalW = max(targetW, contentMain + getFinalWidthPadding(style))
        let finalH = max(targetH, contentCross + getFinalHeightPadding(style))
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
        var cross:Float = 0
        var main:Float = 0
    }
}