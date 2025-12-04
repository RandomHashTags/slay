
import Slay
import SlayUI
import Testing

@Suite
struct StaticHStackTests {

    @Test
    func staticHStackFrameCalculation() {
        let hstack = StaticHStack([
            StaticRectangle(width: 10, height: 10),
            StaticRectangle(width: 20, height: 20),
            StaticRectangle(width: 13, height: 15),
            StaticRectangle(width: 7, height: 2)
        ])
        #expect(hstack.frame.width == 50)
        #expect(hstack.frame.height == 20)
    }
}