
import Slay
import Testing

//@Suite
struct HStackTests {

    //@Test
    func hstackWidthCalculation() {
        var hstack = HStack([
            Text("step 1")
        ])
        #expect(hstack.width == 100)
    }
}