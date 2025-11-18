
import Slay
import SlayUI

@View
struct CustomView: View {

    var frame:Rectangle = .init(width: 0, height: 0) // TODO: fix?

    var body: some View {
        List([
            Rectangle(width: 300, height: 300),
            Rectangle(width: .widthGrow, height: 300),
            Rectangle(width: 300, height: 300)
        ])
    }
}