
import SDL
import SlayKit

public struct SDL2Renderer: RendererProtocol, @unchecked Sendable {

    private var commands:[RenderCommand] = []
    private var renderer:OpaquePointer? = nil

    public init() {
        SDL_Init(SDL_INIT_VIDEO)
    }

    /// - Parameters:
    ///   - fps: Target frames per second to render the window.
    public mutating func render(
        windowSettings: borrowing WindowSettings
    ) {
        let window = SDL_CreateWindow(
            windowSettings.title,
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            windowSettings.width,
            windowSettings.height,
            windowSettings.flagsSDL
        )
        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue)

        var running = true
        var event = SDL_Event()
        while running {
            while SDL_PollEvent(&event) != 0 {
                if event.type == SDL_QUIT.rawValue {
                    running = false
                }
            }
            SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255)
            SDL_RenderClear(renderer)
            drawRects()
            SDL_RenderPresent(renderer)
            SDL_Delay(windowSettings.fpsDelayMS)
        }
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(window)
        SDL_Quit()
    }
}

// MARK: Push
extension SDL2Renderer {
    public mutating func push(_ cmd: RenderCommand) {
        commands.append(cmd)
    }
    private func drawRects() {
        var i = 0
        while i < commands.count {
            if case let .rect(rect, radius, color) = commands[i] {
                var rect = SDL_Rect(
                    x: Int32(rect.x),
                    y: Int32(rect.y),
                    w: Int32(rect.w),
                    h: Int32(rect.h)
                )
                SDL_SetRenderDrawColor(renderer, Uint8(color.0), Uint8(color.1), Uint8(color.2), Uint8(color.3))
                SDL_RenderFillRect(renderer, &rect)
            }
            i +=  1
        }
    }
}

extension WindowSettings {
    public var flagsSDL: UInt32 {
        SDL_WINDOW_SHOWN.rawValue
        | (isFullscreen ? SDL_WINDOW_FULLSCREEN.rawValue : 0)
        | (isResizable ? SDL_WINDOW_RESIZABLE.rawValue : 0)
        | (isAlwaysOnTop ? SDL_WINDOW_ALWAYS_ON_TOP.rawValue : 0)
        | (allowsHighDPI ? SDL_WINDOW_ALLOW_HIGHDPI.rawValue : 0)
    }
}