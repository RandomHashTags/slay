
import Slay
import SlayKit
import SlayUI
import Testing

@Suite
struct YouTubeSubscriptionsViewTests {
    typealias TargetView = YouTubeSubscriptionsView
}

// MARK: Dimensions
extension YouTubeSubscriptionsViewTests {
    @Test
    func youtubeSubscriptionsViewDimensions_1280x720() {
        // root
        #expect(TargetView.Static_1280x720._0 == .rect(
            frame: SlayKit.Rect(x: 0.0, y: 0.0, w: 1280.0, h: 720.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // parent view (VStack)
        #expect(TargetView.Static_1280x720._1 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 1264.0, h: 704.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // subscribed channels (HStack)
        #expect(TargetView.Static_1280x720._2 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 456.0, h: 50.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first channel
        #expect(TargetView.Static_1280x720._3 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 50.0, h: 50.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // second channel
        #expect(TargetView.Static_1280x720._4 == .rect(
            frame: SlayKit.Rect(x: 66.0, y: 8.0, w: 50.0, h: 50.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // filters (HStack)
        #expect(TargetView.Static_1280x720._11 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 66.0, w: 296.0, h: 14.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first filter
        #expect(TargetView.Static_1280x720._12 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 66.0, w: 24.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // second filter
        #expect(TargetView.Static_1280x720._13 == .rect(
            frame: SlayKit.Rect(x: 40.0, y: 66.0, w: 40.0, h: 14.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // videos (List)
        #expect(TargetView.Static_1280x720._18 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 88.0, w: 456.0, h: 208.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // shorts header (Text)
        #expect(TargetView.Static_1280x720._19 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 88.0, w: 48.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // first video
        #expect(TargetView.Static_1280x720._20 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 107.0, w: 466.0, h: 200.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // second video
        #expect(TargetView.Static_1280x720._21 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 107.0, w: 150.0, h: 200.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )
    }
}