
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