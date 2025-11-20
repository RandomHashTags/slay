
import Slay
import SlayUI
import Testing

@Suite
struct StaticVStackTests {

    @Test
    func vstackFrameCalculation() {
        let vstack = StaticVStack([
            StaticRectangle(width: 10, height: 10),
            StaticRectangle(width: 20, height: 20),
            StaticRectangle(width: 13, height: 15),
            StaticRectangle(width: 7, height: 2)
        ])
        #expect(vstack.frame.width == 20)
        #expect(vstack.frame.height == 47)
    }
}