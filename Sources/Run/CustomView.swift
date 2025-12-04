
import Slay
import SlayKit
import SlayUI

@View
struct CustomView: View {
    var body: some View {
        HStack {
            Rectangle(width: 80, height: 80, backgroundColor: .rgba(255, 0, 0, 255))
            Rectangle(height: 80, backgroundColor: .rgba(0, 255, 0, 255))
            Rectangle(height: 20, backgroundColor: .rgba(255, 255, 0, 255))
            Rectangle(width: 20, backgroundColor: .rgba(0, 255, 255, 255))
            //Rectangle(width: 80, backgroundColor: .rgba(255, 255, 0, 255))
            //Text("How much wood can a woodchuck chuck if a woodchuck could chuck wood?; Peter Piper picked a peck of pickled peppers!")
            Rectangle(width: 60, height: 90, backgroundColor: .rgba(0, 0, 255, 255))
        }
    }
}