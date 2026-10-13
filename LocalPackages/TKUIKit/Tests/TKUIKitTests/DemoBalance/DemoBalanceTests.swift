import Foundation
@testable import TKUIKit
import XCTest

final class DemoBalanceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "DemoBalanceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    // MARK: - Parsing

    func testParseAcceptsCommonFormats() {
        XCTAssertEqual(DemoBalanceSettings.parseAmount("1234.5"), decimal("1234.5"))
        XCTAssertEqual(DemoBalanceSettings.parseAmount("1 234,56"), decimal("1234.56"))
        XCTAssertEqual(DemoBalanceSettings.parseAmount("1,234.56"), decimal("1234.56"))
        XCTAssertEqual(DemoBalanceSettings.parseAmount("1.234,56"), decimal("1234.56"))
        XCTAssertEqual(DemoBalanceSettings.parseAmount("  42 "), decimal("42"))
    }

    func testParseTruncatesToTwoFractionDigits() {
        XCTAssertEqual(DemoBalanceSettings.parseAmount("1.999"), decimal("1.99"))
    }

    func testParseRejectsGarbageAndNegatives() {
        XCTAssertNil(DemoBalanceSettings.parseAmount(""))
        XCTAssertNil(DemoBalanceSettings.parseAmount("abc"))
        XCTAssertNil(DemoBalanceSettings.parseAmount("-5"))
        XCTAssertNil(DemoBalanceSettings.parseAmount("1e5"))
    }

    func testParseClampsToMaximum() {
        XCTAssertEqual(DemoBalanceSettings.parseAmount("99999999999999999"), DemoBalanceSettings.maximumAmount)
    }

    // MARK: - Persistence

    func testValuesPersistAcrossInstances() {
        let settings = DemoBalanceSettings(defaults: defaults)
        settings.setEnabled(true)
        settings.setAmount(decimal("1500.25"))
        settings.setCurrency(.ton)

        let reloaded = DemoBalanceSettings(defaults: defaults)
        XCTAssertTrue(reloaded.isEnabled)
        XCTAssertEqual(reloaded.amount, decimal("1500.25"))
        XCTAssertEqual(reloaded.currency, .ton)
    }

    func testDefaultsAreOff() {
        let settings = DemoBalanceSettings(defaults: defaults)
        XCTAssertFalse(settings.isEnabled)
        XCTAssertEqual(settings.amount, 0)
        XCTAssertEqual(settings.currency, .usd)
    }

    // MARK: - Override

    func testDisabledLeavesConfigUntouched() {
        let real = makeConfig(text: "$10")
        let snapshot = DemoBalanceSettings.Snapshot(isEnabled: false, amount: decimal("999"), currency: .usd)
        XCTAssertEqual(real.applyingDemoBalance(snapshot), real)
    }

    func testEnabledReplacesAmountAndRequiresBadge() {
        let real = makeConfig(text: "$10")
        let snapshot = DemoBalanceSettings.Snapshot(isEnabled: true, amount: decimal("999"), currency: .usd)
        let rendered = real.applyingDemoBalance(snapshot)

        XCTAssertNotEqual(rendered, real)
        guard
            case let .content(content) = rendered,
            case let .amount(amount) = content.balance.state
        else {
            return XCTFail("Expected an amount")
        }
        XCTAssertEqual(amount.leadingText, "$")
        XCTAssertTrue(
            amount.accessibilityText.hasPrefix(DemoBalanceStrings.accessibilityAmount("")),
            "VoiceOver must announce the amount as demo"
        )
    }

    func testSecureModeStaysHiddenButStillShowsBadge() {
        let real = BalanceViewConfig.content(BalanceViewContent(balance: .secure()))
        let snapshot = DemoBalanceSettings.Snapshot(isEnabled: true, amount: decimal("999"), currency: .usd)
        XCTAssertEqual(real.applyingDemoBalance(snapshot), real)
    }

    func testShimmerIsNotOverridden() {
        let snapshot = DemoBalanceSettings.Snapshot(isEnabled: true, amount: decimal("999"), currency: .usd)
        XCTAssertEqual(BalanceViewConfig.shimmer.applyingDemoBalance(snapshot), .shimmer)
    }

    func testFormatterSplitsIntegerAndFraction() {
        let output = DemoBalanceFormatter.format(
            amount: decimal("1234.5"),
            currency: .rub,
            locale: Locale(identifier: "en_US")
        )
        XCTAssertEqual(output.textParts.map(\.text), ["1,234.", "50"])
        XCTAssertNil(output.leadingText)
        XCTAssertEqual(output.trailingText, "₽")
        XCTAssertEqual(output.textSize, .regular)
    }

    // MARK: - Helpers

    private func decimal(_ string: String) -> Decimal {
        Decimal(string: string, locale: Locale(identifier: "en_US_POSIX"))!
    }

    private func makeConfig(text: String) -> BalanceViewConfig {
        .content(BalanceViewContent(balance: BalanceViewContent.Balance(text: text)))
    }
}
