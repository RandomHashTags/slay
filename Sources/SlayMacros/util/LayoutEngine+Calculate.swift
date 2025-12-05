
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
    private static func layout(
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
            node.frame = Rect(
                x: origin.x + style.margin.left,
                y: origin.y + style.margin.top,
                w: w + paddingX,
                h: h + paddingY
            )
        } else {
            node.frame = layout(
                parent: node,
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
    private static func layout(
        parent: ViewNode,
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
        let mutateValues:@Sendable ((Bool, Bool), inout Vec2, inout Float, inout Float, Float, inout Float, inout Float, Float, Float) -> Void
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
        var growableWidthChildCount = 0
        var growableHeightChildCount = 0
        var growableChildren = [(childIndex: Int, childNode: ViewNode, growable: (width: Bool, height: Bool))]()
        var childWidthAvailable = widthAvailable
        var childHeightAvailable = heightAvailable
        for (childIndex, childNode) in children.enumerated() {
            let childStyle = childNode.style
            var growable = (width: false, height: false)
            let childWidth:Float
            if let w = childStyle.size.width {
                childWidth = w
            } else {
                childWidth = childWidthAvailable
                growable.width = true
                growableWidthChildCount += 1
            }
            let childHeight:Float
            if let h = childStyle.size.height {
                childHeight = h
            } else {
                childHeight = childHeightAvailable
                growable.height = true
                growableHeightChildCount += 1
            }
            let childAvailable = Vec2(
                x: childWidth,
                y: childHeight
            )
            let frame = layout(
                node: childNode,
                origin: childOrigin,
                available: childAvailable
            )
            let gap = childIndex == children.count-1 ? 0 : style.gap
            if growable.width || growable.height {
                growableChildren.append((childIndex, childNode, growable))
            }
            mutateValues(
                growable,
                &childOrigin,
                &totalChildrenWidth,
                &childWidthAvailable,
                frame.w,
                &totalChildrenHeight,
                &childHeightAvailable,
                frame.h,
                gap
            )
            if !growable.width {
                largestChildWidth = max(frame.w, largestChildWidth)
            }
            if !growable.height {
                largestChildHeight = max(frame.h, largestChildHeight)
            }
        }

        var free:Float = 0
        var childWidth:Float = 0
        var childHeight:Float = 0
        if !growableChildren.isEmpty {
            growableWidthChildCount = max(1, growableWidthChildCount)
            growableHeightChildCount = max(1, growableHeightChildCount)
            if style.axis == .horizontal {
                free = widthAvailable - totalChildrenWidth
                childWidth = free / Float(growableWidthChildCount)
                childHeight = largestChildHeight == 0 ? heightAvailable : largestChildHeight
                for (var childIndex, child, growable) in growableChildren {
                    if growable.width {
                        child.frame.w = childWidth
                        childIndex += 1
                        while childIndex < children.count {
                            let sibling = children[childIndex]
                            offsetSiblingX(sibling: sibling, offset: childWidth)
                            childIndex += 1
                        }
                    }
                    if growable.height {
                        child.frame.h = childHeight
                    }
                }
            } else {
                free = heightAvailable - totalChildrenHeight
                childWidth = largestChildWidth == 0 ? widthAvailable : largestChildWidth
                childHeight = free / Float(growableHeightChildCount)
                for (var childIndex, childNode, growable) in growableChildren {
                    if growable.width {
                        childNode.frame.w = childWidth
                    }
                    if growable.height {
                        childNode.frame.h = childHeight
                        childIndex += 1
                        while childIndex < children.count {
                            let sibling = children[childIndex]
                            offsetSiblingY(sibling: sibling, offset: childHeight)
                            childIndex += 1
                        }
                    }
                }
            }
        }
        parent.customName = """
        
        style=\(style)
        growableChildren.count=\(growableChildren.count)
        free=\(free)
        childWidth=\(childWidth)
        childHeight=\(childHeight)
        targetWidth=\(targetWidth)
        totalChildrenWidth=\(totalChildrenWidth)
        targetHeight=\(targetHeight)
        totalChildrenHeight=\(totalChildrenHeight)
        """
        let finalW = max(targetWidth, totalChildrenWidth + getFinalWidthPadding(style))
        let finalH = max(targetHeight, totalChildrenHeight + getFinalHeightPadding(style))
        return Rect(
            x: origin.x + style.margin.left,
            y: origin.y + style.margin.top,
            w: finalW,
            h: finalH
        )
    }
    private static func offsetSiblingX(
        sibling: ViewNode,
        offset: Float
    ) {
        sibling.frame.x += offset
        for child in sibling.children {
            offsetSiblingX(sibling: child, offset: offset)
        }
    }
    private static func offsetSiblingY(
        sibling: ViewNode,
        offset: Float
    ) {
        sibling.frame.y += offset
        for child in sibling.children {
            offsetSiblingY(sibling: child, offset: offset)
        }
    }
}

// MARK: Mutate horizontal
extension LayoutEngine {
    private static func mutateHorizontalValues(
        growable: (width: Bool, height: Bool),
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
        if growable.width {
            v = gap
        } else {
            v = childWidth + gap
        }
        if !growable.height {
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
        growable: (width: Bool, height: Bool),
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
        if growable.height {
            v = gap
        } else {
            v = childHeight + gap
        }
        if !growable.width {
            width = max(width, childWidth)
        }
        childOrigin.y += v
        height += v
        childHeightAvailable -= v
    }
}