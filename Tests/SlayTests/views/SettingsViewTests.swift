
@testable import DefaultViews
import Slay
import SlayKit
import SlayUI
import Testing

@Suite
struct SettingsViewTests {
    typealias TargetView = SettingsView
}

// MARK: Dimensions
extension SettingsViewTests {
    @Test
    func settingsViewDimensions_1280x720() {
        // root node
        #expect(TargetView.Static_1280x720._0 == .rect(
            frame: SlayKit.Rect(x: 0.0, y: 0.0, w: 200.0, h: 892.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // parent list
        #expect(TargetView.Static_1280x720._1 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 200.0, h: 892.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first list
        #expect(TargetView.Static_1280x720._2 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 128.0, h: 115.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first text
        #expect(TargetView.Static_1280x720._3 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 8.0, w: 104.0, h: 14.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // second text
        #expect(TargetView.Static_1280x720._4 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 30.0, w: 40.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // second list
        #expect(TargetView.Static_1280x720._9 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 131.0, w: 200.0, h: 197.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first text
        #expect(TargetView.Static_1280x720._10 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 131.0, w: 56.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // third list
        #expect(TargetView.Static_1280x720._20 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 336.0, w: 50.0, h: 340.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first rectangle
        #expect(TargetView.Static_1280x720._21 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 336.0, w: 50.0, h: 50.0),
            radius: 0.0,
            color: (0.15686275, 0.0, 0.15686275, 1.0))
        )

        // fourth list
        #expect(TargetView.Static_1280x720._27 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 684.0, w: 128.0, h: 71.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first text
        #expect(TargetView.Static_1280x720._28 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 684.0, w: 104.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // fifth list
        #expect(TargetView.Static_1280x720._32 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 763.0, w: 144.0, h: 55.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first text
        #expect(TargetView.Static_1280x720._33 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 763.0, w: 144.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // sixth list
        #expect(TargetView.Static_1280x720._36 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 826.0, w: 144.0, h: 52.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first text
        #expect(TargetView.Static_1280x720._37 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 826.0, w: 88.0, h: 11.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )

        // seventh list
        #expect(TargetView.Static_1280x720._40 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 886.0, w: 32.0, h: 14.0),
            radius: 0.0,
            color: (0.0, 0.0, 0.0, 0.0))
        )

        // first text
        #expect(TargetView.Static_1280x720._41 == .rect(
            frame: SlayKit.Rect(x: 8.0, y: 886.0, w: 32.0, h: 14.0),
            radius: 0.0,
            color: (1.0, 1.0, 1.0, 1.0))
        )
    }
}