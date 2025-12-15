
#if canImport(GLFWRenderer)
import GLFWRenderer
#endif

#if canImport(SDLRenderer)
import SDLRenderer
#endif

import DefaultViews
import SlayKit


load()

func load() {
    let settings = WindowSettings(
        width: 1280,
        height: 720,
        fps: 30
    )

    guard let fontAtlas = slayDefaultFontAtlas else {
        fatalError("failed to load font")
    }

    let cmds = SettingsView.Static_1280x720.renderCommandsWithOffset(offsetX: 0, offsetY: 100)
    var renderer = GLFWRenderer()
    for i in cmds.indices {
        renderer.push(cmds[i])
    }
    renderer.render(
        fontAtlas: fontAtlas,
        windowSettings: settings
    )
}