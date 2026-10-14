import Foundation
@testable import TKUIKit
import XCTest

final class DemoBalanceMarkerTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "DemoBalanceMarkerTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    // MARK: - Marker follows the settings

    /// Pins the storage keys. The demo settings write these exact keys; if they ever change, this
    /// fails instead of the badge silently stopping to show while demo mode is on.
    func testKeysAreTheStorageContract() {
        XCTAssertEqual(DemoBalanceMarker.Keys.isEnabled, "tk.demoBalance.isEnabled")
        XCTAssertEqual(DemoBalanceMarker.Keys.amount, "tk.demoBalance.amount")
        XCTAssertEqual(DemoBalanceMarker.Keys.currency, "tk.demoBalance.currency")
    }

    func testMarkerFollowsStoredValues() {
        XCTAssertFalse(DemoBalanceMarker.isActive(defaults: defaults))

        enable(amount: "150", currency: "usd")
        XCTAssertTrue(DemoBalanceMarker.isActive(defaults: defaults))
        XCTAssertNotNil(DemoBalanceMarker.gramRow(price: decimal("1.5"), walletCurrencyCode: "USD", defaults: defaults))

        defaults.set(false, forKey: DemoBalanceMarker.Keys.isEnabled)
        XCTAssertFalse(DemoBalanceMarker.isActive(defaults: defaults))
        XCTAssertNil(DemoBalanceMarker.gramRow(price: decimal("1.5"), walletCurrencyCode: "USD", defaults: defaults))
    }

    // MARK: - GRAM row

    func testGramRowFromFiatInWalletCurrency() throws {
        enable(amount: "150", currency: "usd")
        let row = try XCTUnwrap(DemoBalanceMarker.gramRow(price: decimal("1.5"), walletCurrencyCode: "USD", defaults: defaults))
        XCTAssertEqual(row.nanoAmount, "100000000000") // 100 GRAM
        XCTAssertEqual(row.converted, decimal("150"))
    }

    func testGramRowFromGramAmount() throws {
        enable(amount: "10.5", currency: "ton")
        let row = try XCTUnwrap(DemoBalanceMarker.gramRow(price: decimal("2"), walletCurrencyCode: "EUR", defaults: defaults))
        XCTAssertEqual(row.nanoAmount, "10500000000")
        XCTAssertEqual(row.converted, decimal("21"))
    }

    func testGramRowAlwaysCarriesTheDemoTag() throws {
        enable(amount: "1", currency: "ton")
        let row = try XCTUnwrap(DemoBalanceMarker.gramRow(price: decimal("1"), walletCurrencyCode: "USD", defaults: defaults))
        XCTAssertEqual(row.tagText, DemoBalanceMarker.text)
    }

    func testGramRowIsNilForOtherFiatOrZeroPrice() {
        enable(amount: "100", currency: "rub")
        XCTAssertNil(DemoBalanceMarker.gramRow(price: decimal("1"), walletCurrencyCode: "USD", defaults: defaults))

        enable(amount: "100", currency: "usd")
        XCTAssertNil(DemoBalanceMarker.gramRow(price: 0, walletCurrencyCode: "USD", defaults: defaults))
    }

    func testGramRowIsNilWhenDisabled() {
        enable(amount: "100", currency: "ton")
        defaults.set(false, forKey: DemoBalanceMarker.Keys.isEnabled)
        XCTAssertNil(DemoBalanceMarker.gramRow(price: decimal("1"), walletCurrencyCode: "USD", defaults: defaults))
    }

    func testNanoStringTruncatesExtraDigits() {
        XCTAssertEqual(DemoBalanceMarker.nanoString(from: decimal("1.1234567899")), "1123456789")
        XCTAssertEqual(DemoBalanceMarker.nanoString(from: 0), "0")
    }

    // MARK: - Helpers

    private func enable(amount: String, currency: String) {
        defaults.set(true, forKey: DemoBalanceMarker.Keys.isEnabled)
        defaults.set(amount, forKey: DemoBalanceMarker.Keys.amount)
        defaults.set(currency, forKey: DemoBalanceMarker.Keys.currency)
    }

    private func decimal(_ string: String) -> Decimal {
        Decimal(string: string, locale: Locale(identifier: "en_US_POSIX"))!
    }
}
