
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

    var renderer = GLFWRenderer()
    renderer.load(
        fontAtlas: fontAtlas,
        windowSettings: settings
    )
    for i in SettingsView.Static_1280x720.renderCommands.indices {
        renderer.push(SettingsView.Static_1280x720.renderCommands[i])
    }
    renderer.render()

    /*let finalRenderer = renderer
    Task.detached {
        try await Task.sleep(for: .seconds(1))
        SettingsView.Static_1280x720().render(renderer: finalRenderer)
    }
    finalRenderer.render()
    */
}