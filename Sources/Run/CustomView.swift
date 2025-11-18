
import Slay
import SlayKit
import SlayUI

@View
struct CustomView: View {

    var frame = Rectangle(width: 0, height: 0) // TODO: fix?

    var body: some View {
        List([
            Rectangle(width: 300, height: 300, backgroundColor: .rgba(100, 100, 100, 255)),
            Rectangle(height: 300),
            Rectangle(width: 300, height: 300)
        ])
    }

    var backgroundColor: Color? {
        .rgba(255, 0, 0, 255)
    }
}