
import Slay
import SlayKit
import SlayUI

@View
struct SettingsView: View {
    var body: some View {
        List {
            List {
                Text("Airplane Mode")
                Text("Wi-Fi")
                Text("Bluetooth")
                Text("Cellular")
                Text("Personal Hotspot")
                Text("Battery")
            }
            List {
                Text("General")
                Text("Accessibility")
                Text("Camera")
                Text("Control Center")
                Text("Display & Brightness")
                Text("Home Screen & App Library")
                Text("Search")
                Text("Siri")
                Text("Standby")
                Text("Wallpaper")
            }
            List {
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(40, 0, 40, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(50, 0, 50, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(60, 0, 60, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(70, 0, 70, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(80, 0, 80, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(90, 0, 90, 255))
            }
            /*List {
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(100, 0, 100, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(110, 0, 110, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(120, 0, 120, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(130, 0, 130, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(140, 0, 140, 255))
                Rectangle(width: 50, height: 50, backgroundColor: .rgba(150, 0, 150, 255))
            }*/
            List {
                Text("Notifications")
                Text("Sounds & Haptics")
                Text("Focus")
                Text("Screen Time")
            }
            /*List {
                Text("Face ID & Passcode")
                Text("Emergency SOS")
                Text("Privacy & Security")
            }
            List {
                Text("Game Center")
                Text("iCloud")
                Text("Wallet & Apple Pay")
            }
            List {
                Text("Apps")
            }*/
        }
    }
}

/*
struct Static_1280x720 {
    // root
    static let _0: RenderCommand = .rect(frame: SlayKit.Rect(x: 0.0, y: 0.0, w: 1280.0, h: 720.0), radius: 0.0, color: (0.0, 0.0, 0.0, 0.0))

    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FD | List
    static let _1: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 0.0, h: 0.0), radius: 0.0, color: (0.0, 0.0, 0.0, 0.0))

    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0 | List
    static let _2: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 0.0, h: 0.0), radius: 0.0, color: (0.0, 0.0, 0.0, 0.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0Child0
    static let _3: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 104.0, h: 14.0), radius: 0.0, color: (0.0, 0.0, 0.0, 0.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0Child1
    static let _4: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 30.0, w: 40.0, h: 11.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0Child2
    static let _5: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 49.0, w: 72.0, h: 11.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0Child3
    static let _6: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 68.0, w: 64.0, h: 11.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0Child4
    static let _7: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 87.0, w: 128.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild0Child5
    static let _8: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 109.0, w: 56.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))

    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1 | List
    static let _9: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 0.0, h: 0.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child0
    static let _10: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 56.0, h: 11.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child1
    static let _11: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 27.0, w: 104.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child2
    static let _12: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 49.0, w: 48.0, h: 11.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child3
    static let _13: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 68.0, w: 112.0, h: 11.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child4
    static let _14: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 87.0, w: 160.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child5
    static let _15: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 109.0, w: 200.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child6
    static let _16: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 131.0, w: 48.0, h: 11.0), radius: 0.0, color: (0.0, 0.0, 0.0, 0.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child7
    static let _17: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 150.0, w: 32.0, h: 11.0), radius: 0.0, color: (0.0, 0.0, 0.0, 0.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child8
    static let _18: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 169.0, w: 56.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild1Child9
    static let _19: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 191.0, w: 72.0, h: 14.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))

    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2 | List
    static let _20: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 0.0, h: 0.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2Child0
    static let _21: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 50.0, h: 50.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2Child1
    static let _22: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 66.0, w: 50.0, h: 50.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2Child2
    static let _23: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 124.0, w: 50.0, h: 50.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2Child3
    static let _24: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 182.0, w: 50.0, h: 50.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2Child4
    static let _25: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 240.0, w: 50.0, h: 50.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    // 8AA86061-8B77-45CE-BA0F-D9F0CDAB04FDChild2Child5
    static let _26: RenderCommand = .rect(frame: SlayKit.Rect(x: 8.0, y: 298.0, w: 50.0, h: 50.0), radius: 0.0, color: (1.0, 1.0, 1.0, 1.0))
    static let renderCommands: [27 of RenderCommand] = [Self._0, Self._1, Self._2, Self._3, Self._4, Self._5, Self._6, Self._7, Self._8, Self._9, Self._10, Self._11, Self._12, Self._13, Self._14, Self._15, Self._16, Self._17, Self._18, Self._19, Self._20, Self._21, Self._22, Self._23, Self._24, Self._25, Self._26]
}
*/