
#if canImport(GLFWRenderer)
import GLFWRenderer
#endif

#if canImport(SDLRenderer)
import SDLRenderer
#endif

import SlayKit


load()

func load() {
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

    let fontAtlas = FontAtlas(
        ttfPath: "/usr/share/fonts/Adwaita/AdwaitaMono-Regular.ttf",
        pixelSize: slayDefaultFontSize
    )

    renderer.render(
        fontAtlas: fontAtlas,
        windowSettings: settings
    )
}