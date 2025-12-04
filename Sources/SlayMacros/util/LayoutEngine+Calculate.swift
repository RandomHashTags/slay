
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
            node.frame = layout(
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
        let widthAvailable:Float = targetWidth - paddingX
        let heightAvailable:Float = targetHeight - paddingY
        let mutateValues:@Sendable (Bool, inout Vec2, inout Float, inout Float, Float, inout Float, inout Float, Float, Float) -> Void
        let getFinalWidthPadding:(Style) -> Float
        let getFinalHeightPadding:(Style) -> Float
        
        if style.axis == .horizontal {
            mutateValues = mutateHorizontalValues
            getFinalWidthPadding = { $0.padding.right }
            getFinalHeightPadding = { $0.padding.bottom }
        } else {
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
                x: childWidth,
                y: childHeight
            )
            let frame = layout(
                node: child,
                origin: childOrigin,
                available: childAvailable
            )
            let gap = childIndex == children.count-1 ? 0 : style.gap
            if isGrowable {
                growableChildren.append((childIndex, child))
            }
            mutateValues(
                isGrowable,
                &childOrigin,
                &totalChildrenWidth,
                &childWidthAvailable,
                frame.w,
                &totalChildrenHeight,
                &childHeightAvailable,
                frame.h,
                gap
            )
            largestChildWidth = max(frame.w, largestChildWidth)
            largestChildHeight = max(frame.h, largestChildHeight)
        }

        // TODO: fix | child widths are always dynamically resized even if a fixed size was provided

        if !growableChildren.isEmpty {
            let freeWidth = widthAvailable - totalChildrenWidth
            //let freeHeight = largestChildHeight
            //fatalError("test;freeWidth=\(freeWidth);style.axis=\(style.axis);widthAvailable=\(widthAvailable);totalChildrenWidth=\(totalChildrenWidth);heightAvailable=\(heightAvailable);totalChildrenHeight=\(totalChildrenHeight);largestChildWidth=\(largestChildWidth);largestChildHeight=\(largestChildHeight)")
            let childWidth = freeWidth / Float(growableChildren.count)
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
}

// MARK: Mutate horizontal
extension LayoutEngine {
    private static func mutateHorizontalValues(
        isGrowable: Bool,
        childOrigin: inout Vec2,
        width: inout Float,
        childWidthAvailable: inout Float,
        childWidth: Float,
        height: inout Float,
        childHeightAvailable: inout Float,
        childHeight: Float,
        gap: Float
    ) {
        let v:Float
        if isGrowable {
            v = gap
        } else {
            v = childWidth + gap
            height = max(height, childHeight)
        }
        childOrigin.x += v
        width += v
        childWidthAvailable -= v
    }
}

// MARK: Mutate vertical
extension LayoutEngine {
    private static func mutateVerticalValues(
        isGrowable: Bool,
        childOrigin: inout Vec2,
        width: inout Float,
        childWidthAvailable: inout Float,
        childWidth: Float,
        height: inout Float,
        childHeightAvailable: inout Float,
        childHeight: Float,
        gap: Float
    ) {
        let v:Float
        if isGrowable {
            v = gap
        } else {
            v = childHeight + gap
            width = max(width, childWidth)
        }
        childOrigin.y += v
        height += v
        childHeightAvailable -= v
    }
}