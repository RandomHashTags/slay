
import SlayKit

extension LayoutEngine {
    func layout(
        width: Int32,
        height: Int32
    ) {
        root.style.size.width = Float(width)
        root.style.size.height = Float(height)
        root.frame.w = Float(width)
        root.frame.h = Float(height)
        Self.layout(
            node: root,
            origin: .init(x: 0, y: 0),
            available: .init(x: Float(width), y: Float(height))
        )
    }
}

// MARK: Layout
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
        } else {
            node.frame = layoutNew(
                origin: origin,
                style: style,
                targetWidth: targetWidth,
                targetHeight: targetHeight,
                paddingX: paddingX,
                paddingY: paddingY,
                children: node.children
            )
        }
        return node.frame
    }
}

// MARK: Layout children
extension LayoutEngine {
    static func layout(
        origin: Vec2,
        style: Style,
        targetWidth: Float,
        targetHeight: Float,
        paddingX: Float,
        paddingY: Float,
        children: [ViewNode]
    ) -> Rect {
        // Flex layout (simplified): collect fixed-size and flex items, no min/max for brevity.
        let widthAvailable:Float
        let heightAvailable:Float
        let getChildWidth:(Style) -> Float?
        let getChildHeight:(Style) -> Float?
        let getOffset:(_ x: Float, _ y: Float) -> Float
        let getChildAvailX:(_ width: Float, _ height: Float) -> Float
        let getChildAvailY:(_ width: Float, _ height: Float) -> Float
        let getChildOffset:(Rect) -> Float
        let mutateOffset:(_ xOffset: inout Float, _ yOffset: inout Float, _ amount: Float) -> Void
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
            getChildOffset = { $0.w }
            mutateOffset = { _, yOffset, amount in yOffset += amount }
            getContentHeight = { $0.w }
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
            getChildOffset = { $0.h }
            mutateOffset = { xOffset, _, amount in xOffset += amount }
            getContentHeight = { $0.h }
            getFinalWidthPadding = { $0.padding.bottom }
            getFinalHeightPadding = { $0.padding.right }
        }

        // Simple single-line or wrap lines
        var lines = [Line()]
        var current = Vec2(x: 0, y: 0)
        for child in children {
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
        var width:Float = 0
        var height:Float = 0

        for (lineIndex, line) in lines.enumerated() {
            let targetGap:Float
            if lineIndex != line.items.count-1 { // is not last
                targetGap = style.gap
            } else {
                targetGap = 0
            }

            var fixed:Float = 0
            var flexSum:Float = 0
            for child in line.items {
                let childStyle = child.style
                if let fixedWidth = getChildWidth(childStyle) {
                    fixed += Float(fixedWidth)
                } else {
                    flexSum += childStyle.grow
                }
                fixed += targetGap
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
                let childAvailable = Vec2(
                    x: getChildAvailX(childWidth, childHeight),
                    y: getChildAvailY(childWidth, childHeight)
                )
                let childOrigin = Vec2(
                    x: origin.x + style.margin.left + getOffset(offset, xOffset),
                    y: origin.y + style.margin.top + getOffset(yOffset, offset)
                )
                let frame = layout(
                    node: child,
                    origin: childOrigin,
                    available: childAvailable
                )
                let gap = lineItemIndex == line.items.count-1 ? 0 : style.gap
                offset += getChildOffset(frame) + gap
                width = max(width, offset)
                height += getContentHeight(frame) + gap
            }
            mutateOffset(&xOffset, &yOffset, line.height + style.gap)
        }
        let finalW = max(targetWidth, width + getFinalWidthPadding(style))
        let finalH = min(targetHeight, height + getFinalHeightPadding(style))
        return Rect(
            x: origin.x + style.margin.left,
            y: origin.y + style.margin.top,
            w: finalW,
            h: finalH
        )
    }
}

// MARK: Layout children (new)
extension LayoutEngine {
    static func layoutNew(
        origin: Vec2,
        style: Style,
        targetWidth: Float,
        targetHeight: Float,
        paddingX: Float,
        paddingY: Float,
        children: [ViewNode]
    ) -> Rect {
        let widthAvailable:Float
        let heightAvailable:Float
        let getChildAvailX:(_ width: Float, _ height: Float) -> Float
        let getChildAvailY:(_ width: Float, _ height: Float) -> Float
        let mutateValues:@Sendable (Bool, inout Vec2, inout Float, inout Float, inout Float, Float, inout Float, inout Float, inout Float, Float, Float) -> Void
        let getFinalWidthPadding:(Style) -> Float
        let getFinalHeightPadding:(Style) -> Float
        
        if style.axis == .horizontal {
            widthAvailable = targetWidth - paddingX
            heightAvailable = targetHeight - paddingY
            getChildAvailX = { width, _ in width }
            getChildAvailY = { _, height in height }
            mutateValues = mutateHorizontalValues
            getFinalWidthPadding = { $0.padding.right }
            getFinalHeightPadding = { $0.padding.bottom }
        } else {
            widthAvailable = targetHeight - paddingY
            heightAvailable = targetWidth - paddingX
            getChildAvailX = { _, height in height }
            getChildAvailY = { width, _ in width }
            mutateValues = mutateVerticalValues
            getFinalWidthPadding = { $0.padding.bottom }
            getFinalHeightPadding = { $0.padding.right }
        }

        var totalChildrenWidth:Float = 0
        var largestChildWidth:Float = 0
        var totalChildrenHeight:Float = 0
        var largestChildHeight:Float = 0
        var childOrigin = Vec2(
            x: origin.x + style.padding.left + style.margin.left,
            y: origin.y + style.padding.top + style.margin.top
        )
        var growableChildren = [(childIndex: Int, child: ViewNode)]()
        var childWidthAvailable = widthAvailable
        var childHeightAvailable = heightAvailable
        for (childIndex, child) in children.enumerated() {
            let childStyle = child.style
            var isGrowable = false
            let childWidth:Float
            if let w = childStyle.size.width {
                childWidth = w
            } else {
                childWidth = childWidthAvailable
                isGrowable = true
            }
            let childHeight:Float
            if let h = childStyle.size.height {
                childHeight = h
            } else {
                childHeight = childHeightAvailable
                isGrowable = true
            }
            let childAvailable = Vec2(
                x: getChildAvailX(childWidth, childHeight),
                y: getChildAvailY(childWidth, childHeight)
            )
            let frame = layout(
                node: child,
                origin: childOrigin,
                available: childAvailable
            )
            if isGrowable {
                growableChildren.append((childIndex, child))
            }
            let gap = childIndex == children.count-1 ? 0 : style.gap
            mutateValues(
                isGrowable,
                &childOrigin,
                &totalChildrenWidth,
                &childWidthAvailable,
                &largestChildWidth,
                frame.w,
                &totalChildrenHeight,
                &childHeightAvailable,
                &largestChildHeight,
                frame.h,
                gap
            )
        }
        if !growableChildren.isEmpty {
            let freeWidth = getChildAvailX(widthAvailable - totalChildrenWidth, heightAvailable - totalChildrenHeight)
            //fatalError("test;freeWidth=\(freeWidth);style.axis=\(style.axis);widthAvailable=\(widthAvailable);totalChildrenWidth=\(totalChildrenWidth);heightAvailable=\(heightAvailable);totalChildrenHeight=\(totalChildrenHeight)")
            let childWidth = freeWidth / Float(growableChildren.count)
            totalChildrenWidth = getChildAvailX(targetWidth, largestChildWidth)
            totalChildrenHeight = getChildAvailY(largestChildHeight, targetHeight)
            if style.axis == .horizontal {
                for (var childIndex, child) in growableChildren {
                    child.frame.w = childWidth
                    childIndex += 1
                    while childIndex < children.count {
                        let sibling = children[childIndex]
                        sibling.frame.x += childWidth
                        childIndex += 1
                    }
                }
            } else {
                for (var childIndex, child) in growableChildren {
                    child.frame.h = childWidth
                    childIndex += 1
                    while childIndex < children.count {
                        let sibling = children[childIndex]
                        sibling.frame.y += childWidth
                        childIndex += 1
                    }
                }
            }
        }

        let finalW = max(targetWidth, totalChildrenWidth + getFinalWidthPadding(style))
        let finalH = max(targetHeight, totalChildrenHeight + getFinalHeightPadding(style))
        return Rect(
            x: origin.x + style.margin.left,
            y: origin.y + style.margin.top,
            w: finalW,
            h: finalH
        )
    }
    private static func mutateHorizontalValues(
        isGrowable: Bool,
        childOrigin: inout Vec2,
        width: inout Float,
        childWidthAvailable: inout Float,
        largestChildWidth: inout Float,
        childWidth: Float,
        height: inout Float,
        childHeightAvailable: inout Float,
        largestChildHeight: inout Float,
        childHeight: Float,
        gap: Float
    ) {
        let v:Float
        if isGrowable {
            v = gap
        } else {
            v = childWidth + gap
            height = max(height, childHeight)
            largestChildWidth = max(childWidth, largestChildWidth)
            largestChildHeight = max(childHeight, largestChildHeight)
        }
        childOrigin.x += v
        width += v
        childWidthAvailable -= v
    }
    private static func mutateVerticalValues(
        isGrowable: Bool,
        childOrigin: inout Vec2,
        width: inout Float,
        childWidthAvailable: inout Float,
        largestChildWidth: inout Float,
        childWidth: Float,
        height: inout Float,
        childHeightAvailable: inout Float,
        largestChildHeight: inout Float,
        childHeight: Float,
        gap: Float
    ) {
        let v:Float
        if isGrowable {
            v = gap
        } else {
            v = childHeight + gap
            width = max(width, childWidth)
            largestChildWidth = max(childWidth, largestChildWidth)
            largestChildHeight = max(childHeight, largestChildHeight)
        }
        childOrigin.y += v
        height += v
        childHeightAvailable -= v
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