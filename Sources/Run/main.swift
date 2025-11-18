
import GLFWRenderer
import SlayKit
import SlayUI
import SDLRenderer

public func box(
    _ arena: Arena,
    _ id: NodeId,
    bg: Color,
    radius: Float = 0,
    renderer: inout some RendererProtocol
) {
    let frame = arena.layout(of: id)
    renderer.push(.rect(frame: frame, radius: radius, bg: (bg.red, bg.green, bg.blue, bg.alpha)))
}

// Tiny demo: row with 3 boxes, middle one grows.
var arena = Arena()
let root = arena.create(Style(axis: .row, padding: Insets(left: 8, top: 8, right: 8, bottom: 8), gap: 8), name: "root")
let rect1 = Rectangle(width: 80, height: 80, backgroundColor: .red)
let rect2 = Rectangle(height: 80, backgroundColor: .green)
let rect3 = Rectangle(width: 60, height: 90, backgroundColor: .blue)
let a = arena.create(rect1)
let b = arena.create(rect2)
let c = arena.create(rect3)
arena.setChildren(root, [a, b, c])

let settings = WindowSettings(
    width: 1280,
    height: 720,
    fps: 30
)
arena.compute(root: root, available: Vec2(x: Float(settings.width), y: Float(settings.height)))

var renderer = GLFWRenderer()
renderer.render(arena, a, bg: rect1.backgroundColor)
renderer.render(arena, b, bg: rect2.backgroundColor)
renderer.render(arena, c, bg: rect3.backgroundColor)

renderer.render(
    windowSettings: settings,
    arena: arena
)

extension Arena {
    @discardableResult
    func create(
        _ view: some View,
        name: String? = nil
    ) -> NodeId {
        let id = NodeId(raw: nodes.count)
        nodes.append(Node(style: view.style, name: name))
        return id
    }
}

extension View {
    var style: Style {
        var s = Style()
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

extension RendererProtocol {
    mutating func render(
        _ arena: Arena,
        _ id: NodeId,
        bg: Color?,
        radius: Float = 0
    ) {
        let frame = arena.layout(of: id)
        push(.rect(frame: frame, radius: radius, bg: (bg?.red ?? 0, bg?.green ?? 0, bg?.blue ?? 0, bg?.alpha ?? 0)))
    }
}