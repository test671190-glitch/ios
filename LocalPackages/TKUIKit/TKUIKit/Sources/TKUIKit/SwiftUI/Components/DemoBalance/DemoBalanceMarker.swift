import Combine
import SwiftUI
import UIKit

// MARK: - DemoBalanceMarker
//
// Self-contained file. It does not call any other demo-balance code: it reads the raw
// `UserDefaults` keys itself, so it keeps working if `DemoBalanceSettings.swift` or
// `DemoBalanceOverride.swift` break, and it can be restored on its own.
//
// It is the single source of truth for the "DEMO" marker AND for the demo GRAM row.
// Both come from the same `isActive` check, so the demo amount in the token list can never
// be shown without its marker, and the header always carries the badge while demo is on.
//
// Hooks into the rest of the project (each is one line, grep for `DemoBalanceMarker`):
//   1. `BalanceSwiftUIView.body`            → `.demoBalanceBadge()`
//   2. `WalletBalanceListMapper.mapTonItem` → `DemoBalanceMarker.gramRow(...)`
//   3. `WalletBalanceViewModel`             → refresh the list on `DemoBalanceMarker.didChange`
//
// The marker is drawn into the regular view hierarchy, so it is also what iOS captures for the
// app switcher snapshot.

public enum DemoBalanceMarker {
    /// Text of the badge and of the token tag.
    public static let text = "DEMO"

    /// Keys written by `DemoBalanceSettings`. Duplicated on purpose to stay independent;
    /// `DemoBalanceMarkerTests` fails if the two files ever drift apart.
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

    // MARK: Token tag

    /// Orange "DEMO" tag shown next to the token title.
    public static var tagConfiguration: TKTagView.Configuration {
        .accentTag(text: text, color: .Accent.orange)
    }

    // MARK: GRAM row

    /// Demo values for the GRAM row of the token list. The tag is part of the result, so a
    /// caller cannot take the amount without the marker.
    public struct GramRow: Equatable {
        /// Amount in nano-GRAM (9 fraction digits), ready for the list formatter.
        public let nanoAmount: String
        /// Value of `nanoAmount` in the wallet's fiat currency.
        public let converted: Decimal
        /// Must be appended to the row's tags.
        public let tag: TKTagView.Configuration
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
            tag: tagConfiguration
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
public struct DemoBalanceBadge: View {
    public init() {}

    public var body: some View {
        Text(DemoBalanceMarker.text)
            .font(.system(size: 12, weight: .bold))
            .kerning(1)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color(UIColor.Accent.orange)))
            .fixedSize()
            .allowsHitTesting(false)
            .accessibilityLabel(DemoBalanceMarker.text)
            .accessibilityIdentifier("demo_balance_badge")
    }
}

/// Watches the demo flag on its own, independent of `DemoBalanceSettings`.
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
