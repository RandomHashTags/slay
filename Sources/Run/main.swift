
import GLFWRenderer
import SlayKit
import SDLRenderer

public func box(
    _ arena: Arena,
    _ id: NodeId,
    bg: (UInt8, UInt8, UInt8, UInt8) = (220, 220, 220, 255),
    radius: Float = 0,
    renderer: inout some RendererProtocol
) {
    let frame = arena.layout(of: id)
    renderer.push(.rect(frame: frame, radius: radius, bg: bg))
}

// Tiny demo: row with 3 boxes, middle one grows.
var arena = Arena()
let root = arena.create(Style(axis: .row, padding: Insets(left: 8, top: 8, right: 8, bottom: 8), gap: 8), name: "root")
let a = arena.create(Style(size: Size(w: 80, h: 80)), name: "A")
let b = arena.create(Style(grow: 1, size: Size(h: 80)), name: "B")
let c = arena.create(Style(size: Size(w: 60, h: 80)), name: "C")
arena.setChildren(root, [a, b, c])

let settings = WindowSettings(
    width: 1280,
    height: 720,
    fps: 30
)
arena.compute(root: root, available: Vec2(x: Float(settings.width), y: Float(settings.height)))

var renderer = GLFWRenderer()
box(arena, a, bg: (255, 0, 0, 255), renderer: &renderer)
box(arena, b, bg: (0, 255, 0, 255), renderer: &renderer)
box(arena, c, bg: (0, 0, 255, 255), renderer: &renderer)

renderer.render(
    windowSettings: settings,
    arena: arena
)