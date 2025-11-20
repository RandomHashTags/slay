
import Slay
import SlayKit
import SlayUI

@View
struct CustomView: StaticView {

    var frame = StaticRectangle(width: 0, height: 0) // TODO: fix?

    var body: some StaticView {
        StaticList([
            StaticRectangle(width: 80, height: 80, backgroundColor: .rgba(255, 0, 0, 255)),
            StaticRectangle(height: 80, backgroundColor: .rgba(0, 255, 0, 255)),
            StaticRectangle(width: 60, height: 90, backgroundColor: .rgba(0, 0, 255, 255))
        ])
    }

    var backgroundColor: Color? {
        .rgba(255, 0, 0, 255)
    }
}