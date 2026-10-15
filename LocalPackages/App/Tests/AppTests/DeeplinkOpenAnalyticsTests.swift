@testable import App
import KeeperCore
import TKCore
import XCTest

final class DeeplinkOpenAnalyticsTests: XCTestCase {
    func testUniversalLinksAreTheOnesArrivingOverHttps() {
        XCTAssertEqual(DeeplinkOpen.From(link: "https://app.example.com/transfer/EQD?amount=1"), .universalLink)
        XCTAssertEqual(DeeplinkOpen.From(link: "HTTPS://app.example.com/staking"), .universalLink)
        XCTAssertEqual(DeeplinkOpen.From(link: "tonkeeprdemomode://staking"), .appLink)
        XCTAssertEqual(DeeplinkOpen.From(link: "ton://transfer/EQD"), .appLink)
        XCTAssertEqual(DeeplinkOpen.From(link: "tc://?v=2&id=abc"), .appLink)
    }

    func testLinkTypeFollowsTheParsedDeeplink() {
        XCTAssertEqual(DeeplinkOpen.LinkType(deeplink: .staking), .staking)
        XCTAssertEqual(DeeplinkOpen.LinkType(deeplink: .main), .main)
        XCTAssertEqual(DeeplinkOpen.LinkType(deeplink: .browser(network: nil)), .browser)
        XCTAssertEqual(DeeplinkOpen.LinkType(deeplink: .action(eventId: "0x1")), .action)
        XCTAssertEqual(DeeplinkOpen.LinkType(deeplink: .story(storyId: "welcome")), .story)
    }

    func testPendingDeeplinkRoutesTheLatestAndReportsEveryLinkWithItsLaunchState() {
        var state = PendingDeeplinkState()

        state.append("tonkeeprdemomode://staking", isColdStart: true)
        state.append("tonkeeprdemomode://swap", isColdStart: false)

        let drained = state.drain()
        XCTAssertEqual(drained.deeplink as? String, "tonkeeprdemomode://swap")
        XCTAssertEqual(drained.analyticsContexts, [
            DeeplinkOpenAnalyticsContext(link: "tonkeeprdemomode://staking", isColdStart: true),
            DeeplinkOpenAnalyticsContext(link: "tonkeeprdemomode://swap", isColdStart: false),
        ])
        XCTAssertNil(state.deeplink)
        XCTAssertTrue(state.analyticsContexts.isEmpty)
    }
}
