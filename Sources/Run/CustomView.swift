
import Slay
import SlayKit
import SlayUI

@View
struct CustomView: View {

    var frame = Rectangle(width: 0, height: 0) // TODO: fix?

    var body: some View {
        List([
            Rectangle(width: 80, height: 80, backgroundColor: .rgba(255, 0, 0, 255)),
            Rectangle(height: 80, backgroundColor: .rgba(0, 255, 0, 255)),
            Rectangle(width: 60, height: 90, backgroundColor: .rgba(0, 0, 255, 255))
        ])
    }

    var backgroundColor: Color? {
        .rgba(255, 0, 0, 255)
    }
}