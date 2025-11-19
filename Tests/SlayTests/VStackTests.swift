
import Slay
import SlayUI
import Testing

@Suite
struct VStackTests {

    @Test
    func vstackFrameCalculation() {
        let vstack = VStack([
            Rectangle(width: 10, height: 10),
            Rectangle(width: 20, height: 20),
            Rectangle(width: 13, height: 15),
            Rectangle(width: 7, height: 2)
        ])
        #expect(vstack.frame.width == 20)
        #expect(vstack.frame.height == 47)
    }
}