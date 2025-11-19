
import Slay
import SlayUI
import Testing

@Suite
struct HStackTests {

    @Test
    func hstackFrameCalculation() {
        let hstack = HStack([
            Rectangle(width: 10, height: 10),
            Rectangle(width: 20, height: 20),
            Rectangle(width: 13, height: 15),
            Rectangle(width: 7, height: 2)
        ])
        #expect(hstack.frame.width == 50)
        #expect(hstack.frame.height == 20)
    }
}