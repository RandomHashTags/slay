
import SlayKit

final class ViewNode: CustomStringConvertible {
    let type:ViewType
    var children:[ViewNode]
    var style = Style(
        axis: .vertical,
        padding: Insets(left: 0, top: 0, right: 0, bottom: 0),
        gap: 0
    )
    var customName:String? = nil
    var frame = Rect(x: 0, y: 0, w: 0, h: 0)

    init(
        type: ViewType,
        children: [ViewNode] = [],
        name: String? = nil
    ) {
        self.type = type
        var c = type.children
        c.append(contentsOf: children)
        self.children = c

        self.customName = name
        if let width = type.frame._width {
            style.size.width = Float(width)
        }
        if let height = type.frame._height {
            style.size.height = Float(height)
        } 
        style.axis = type.axis
        style.gap = type.gap
    }

    var name: String {
        guard let customName else { return type.name }
        return type.name + " (\(customName))"
    }

    var description: String {
        "ViewNode(type: .\(type), children: \(children), style: \(style), name: \(name), frame: \(frame))"
    }
}