
import SlayKit

// MARK: Compute
extension LayoutEngine {
    func layout(
        width: Int32,
        height: Int32
    ) {
        Self.layout(
            node: root,
            origin: .init(x: 0, y: 0),
            available: .init(x: Float(width), y: Float(height))
        )
    }
}

// MARK: Calculate
extension LayoutEngine {
    /// - Returns: The computed layout for the node.
    @discardableResult
    static func layout(
        node: ViewNode,
        origin: Vec2,
        available: Vec2
    ) -> Rect {
        let style = node.style
        let paddingX = style.padding.left + style.padding.right
        let paddingY = style.padding.top + style.padding.bottom
        let marginX = style.margin.left + style.margin.right
        let marginY = style.margin.top + style.margin.bottom

        let hasFixedWidth = style.size.width != nil
        let hasFixedHehgith = style.size.height != nil
        var targetWidth = Float(hasFixedWidth ? style.size.width! : available.x - marginX)
        var targetHeight = Float(hasFixedHehgith ? style.size.height! : available.y - marginY)

        if let aspectRatio = style.aspectRatio {
            if !hasFixedWidth && hasFixedHehgith {
                targetWidth = targetHeight * aspectRatio
            } else if hasFixedWidth && !hasFixedHehgith {
                targetHeight = targetWidth / aspectRatio
            }
        }

        if node.children.isEmpty {
            let w = max(0, targetWidth - paddingX)
            let h = max(0, targetHeight - paddingY)
            node.frame = Rect(
                x: origin.x + style.margin.left,
                y: origin.y + style.margin.top,
                w: w + paddingX,
                h: h + paddingY
            )
            return node.frame
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
            widthAvailable = targetWidth - paddingX
            heightAvailable = targetHeight - paddingY
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
            widthAvailable = targetHeight - paddingY
            heightAvailable = targetWidth - paddingX
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
            let childStyle = child.style
            let childHeight = getChildHeight(childStyle) ?? 0 // flex items initially 0
            let childWidth = getChildWidth(childStyle) ?? 0 // flex items initially 0
            if style.wrap && current.x + childWidth > widthAvailable && !lines.last!.items.isEmpty {
                lines.append(Line())
                current = Vec2(x: 0, y: 0)
            }
            lines[lines.count-1].items.append(child)
            current.x += childWidth + style.gap
            lines[lines.count-1].height = max(lines.last!.height, childHeight)
        }

        var yOffset = style.padding.top
        var xOffset = style.padding.left
        var contentWidth:Float = 0
        var contentHeight:Float = 0

        for (lineIndex, line) in lines.enumerated() {
            var fixed:Float = 0
            var flexSum:Float = 0
            for child in line.items {
                let childStyle = child.style
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
                let childStyle = child.style
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
                let frame = layout(node: child, origin: childOrigin, available: childAvail)
                offset += getLaidOffset(frame) + (lineItemIndex == line.items.count-1 ? 0 : style.gap)
                contentWidth = max(contentWidth, offset)
                contentHeight += getContentHeight(frame)
            }
            mutateOffset(&xOffset, &yOffset, line.height + style.gap)
        }

        let finalW = max(targetWidth, contentWidth + getFinalWidthPadding(style))
        let finalH = max(targetHeight, contentHeight + getFinalHeightPadding(style))
        node.frame = Rect(
            x: origin.x + style.margin.left,
            y: origin.y + style.margin.top,
            w: finalW,
            h: finalH
        )
        return node.frame
    }
}

// MARK: Line
extension LayoutEngine {
    struct Line {
        var items  = [ViewNode]()
        var height:Float = 0
        var width:Float = 0
    }
}