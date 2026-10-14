import Combine
import Foundation
import SwiftUI

// MARK: - DemoBalanceMarker
//
// Standalone "DEMO" marker. It imports only Foundation, SwiftUI and Combine, and it does not
// reference any other project file: it reads its own `UserDefaults` keys and returns plain
// values. Other files never need its types; they only receive neutral values, see below.
//
// Call sites in the rest of the project (grep for `DemoBalanceMarker`):
//   1. `BalanceSwiftUIView.body`            → `.demoBalanceBadge()`
//   2. `WalletBalanceListMapper.mapTonItem` → `DemoBalanceMarker.gramRow(...)`
//   3. `WalletBalanceViewModel`             → refresh the list on `DemoBalanceMarker.didChange`
//
// Removing this file therefore needs exactly those three lines removed as well. Nothing else
// in the project changes, and the build reports the lines if they are forgotten.
// Removing any other part of the project leaves this file compiling, because it has no
// dependency on that part.
//
// The marker is drawn into the regular view hierarchy, so it is also what iOS captures for the
// app switcher snapshot.

public enum DemoBalanceMarker {
    /// Text of the badge and of the token tag.
    public static let text = "DEMO"

    /// Keys written by the demo settings. They are the storage contract: `DemoBalanceMarkerTests`
    /// pins them, so a rename on either side fails the tests instead of hiding the marker.
    enum Keys {
        static let isEnabled = "tk.demoBalance.isEnabled"
        static let amount = "tk.demoBalance.amount"
        static let currency = "tk.demoBalance.currency"
    }

    /// `true` while demo mode is on. Every demo value must be gated by this.
    public static func isActive(defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: Keys.isEnabled)
    }

    /// Emits on the main queue whenever the demo state (on/off, amount, currency) changes.
    public static var didChange: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in State.current() }
            .prepend(State.current())
            .removeDuplicates()
            .dropFirst()
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: GRAM row

    /// Demo values for the GRAM row of the token list. `tagText` always comes with the amount,
    /// so the caller cannot take the amount without the marker text.
    public struct GramRow: Equatable {
        /// Amount in nano-GRAM (9 fraction digits), ready for the list formatter.
        public let nanoAmount: String
        /// Value of `nanoAmount` in the wallet's fiat currency.
        public let converted: Decimal
        /// Text of the tag that must be shown next to the GRAM title.
        public let tagText: String
    }

    /// Returns demo values for the GRAM row, or `nil` when demo is off or the amount cannot be
    /// expressed in the wallet's currency (the row then shows the real balance).
    ///
    /// - Parameters:
    ///   - price: price of 1 GRAM in the wallet's fiat currency.
    ///   - walletCurrencyCode: wallet fiat code, e.g. `"USD"`.
    public static func gramRow(
        price: Decimal,
        walletCurrencyCode: String,
        defaults: UserDefaults = .standard
    ) -> GramRow? {
        let state = State.current(defaults: defaults)
        guard state.isEnabled, let amount = state.amount else { return nil }

        let gram: Decimal
        let converted: Decimal
        switch state.currencyCode {
        case "TON":
            gram = amount
            converted = amount * price
        case walletCurrencyCode.uppercased():
            guard price > 0 else { return nil }
            gram = amount / price
            converted = amount
        default:
            // Demo is set in a different fiat than the wallet; no rate to convert with.
            return nil
        }

        return GramRow(
            nanoAmount: nanoString(from: gram),
            converted: rounded(converted, scale: 2),
            tagText: text
        )
    }

    // MARK: Private

    private static let gramFractionDigits: Int16 = 9
    private static let posix = Locale(identifier: "en_US_POSIX")

    struct State: Equatable {
        let isEnabled: Bool
        let amount: Decimal?
        let currencyCode: String

        static func current(defaults: UserDefaults = .standard) -> State {
            let amount = defaults.string(forKey: Keys.amount)
                .flatMap { Decimal(string: $0, locale: posix) }
                .flatMap { $0 >= 0 ? $0 : nil }
            let currency = (defaults.string(forKey: Keys.currency) ?? "usd").uppercased()
            return State(
                isEnabled: defaults.bool(forKey: Keys.isEnabled),
                amount: amount,
                currencyCode: currency
            )
        }
    }

    static func nanoString(from gram: Decimal) -> String {
        var scaled = gram
        for _ in 0 ..< gramFractionDigits {
            scaled *= 10
        }
        let integer = rounded(scaled, scale: 0)
        let text = NSDecimalNumber(decimal: integer).description(withLocale: posix)
        return text.allSatisfy(\.isNumber) ? text : "0"
    }

    static func rounded(_ value: Decimal, scale: Int) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, scale, .down)
        return output
    }
}

// MARK: - Header badge

/// Capsule "DEMO" badge laid over the balance header.
///
/// The colour is fixed on purpose: a warning plate must look the same in both themes.
public struct DemoBalanceBadge: View {
    public init() {}

    public var body: some View {
        Text(DemoBalanceMarker.text)
            .font(.system(size: 12, weight: .bold))
            .kerning(1)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.orange))
            .fixedSize()
            .allowsHitTesting(false)
            .accessibilityLabel(DemoBalanceMarker.text)
            .accessibilityIdentifier("demo_balance_badge")
    }
}

/// Watches the demo flag on its own.
final class DemoBalanceMarkerObserver: ObservableObject {
    @Published private(set) var isActive = DemoBalanceMarker.isActive()
    private var cancellable: AnyCancellable?

    init() {
        cancellable = DemoBalanceMarker.didChange.sink { [weak self] in
            self?.isActive = DemoBalanceMarker.isActive()
        }
    }
}

private struct DemoBalanceBadgeModifier: ViewModifier {
    @StateObject private var observer = DemoBalanceMarkerObserver()

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if observer.isActive {
                DemoBalanceBadge()
                    .offset(y: -6)
            }
        }
    }
}

public extension View {
    /// Overlays the "DEMO" badge while demo mode is on. No-op otherwise.
    func demoBalanceBadge() -> some View {
        modifier(DemoBalanceBadgeModifier())
    }
}
