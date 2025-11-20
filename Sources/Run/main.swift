
#if canImport(GLFWRenderer)
import GLFWRenderer
#endif

#if canImport(SDLRenderer)
import SDLRenderer
#endif

import SlayKit

// Tiny demo: row with 3 boxes, middle one grows.
let settings = WindowSettings(
    width: 1280,
    height: 720,
    fps: 30
)

let cmds = CustomView.Static_1280x720.renderCommands

var renderer = GLFWRenderer()
for i in cmds.indices {
    renderer.push(cmds[i])
}

renderer.render(
    windowSettings: settings
)