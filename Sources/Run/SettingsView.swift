
import Slay
import SlayKit
import SlayUI

@View
struct SettingsView: View {
    var body: some View {
        VStack {
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
                Text("Notifications")
                Text("Sounds & Haptics")
                Text("Focus")
                Text("Screen Time")
            }
            List {
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
            }
        }
    }
}