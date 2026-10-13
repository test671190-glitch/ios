import Combine
import Foundation

/// Local, display-only "demo balance" mode.
///
/// When enabled, the wallet header shows a number typed in by the user instead of the real
/// total. It is cosmetic only:
/// - it is stored in `UserDefaults` on this device and never leaves it;
/// - it is read exclusively at render time by `BalanceSwiftUIView`;
/// - wallet state, keys, nodes, history, send/receive and fee calculation never see it,
///   so the demo amount can never be spent or used anywhere.
public final class DemoBalanceSettings: ObservableObject {
    public static let shared = DemoBalanceSettings()

    /// The largest amount the field accepts; keeps the header readable.
    public static let maximumAmount = Decimal(string: "999999999999.99", locale: Locale(identifier: "en_US_POSIX")) ?? 0

    public enum Currency: String, CaseIterable, Sendable {
        case usd
        case eur
        case rub
        case ton

        public var code: String {
            switch self {
            case .usd: "USD"
            case .eur: "EUR"
            case .rub: "RUB"
            case .ton: "TON"
            }
        }

        public var symbol: String {
            switch self {
            case .usd: "$"
            case .eur: "€"
            case .rub: "₽"
            case .ton: "TON"
            }
        }

        /// `true` puts the symbol before the number (`$1,000`), `false` after it (`1 000 ₽`).
        public var isSymbolLeading: Bool {
            switch self {
            case .usd, .eur: true
            case .rub, .ton: false
            }
        }
    }

    /// Immutable copy of the current values, safe to pass into render code.
    public struct Snapshot: Hashable, Sendable {
        public let isEnabled: Bool
        public let amount: Decimal
        public let currency: Currency
    }

    @Published public private(set) var isEnabled: Bool
    @Published public private(set) var amount: Decimal
    @Published public private(set) var currency: Currency

    /// Emits after a change has been persisted. Subscribe on the main queue.
    public var didChange: AnyPublisher<Void, Never> {
        didChangeSubject.eraseToAnyPublisher()
    }

    public var snapshot: Snapshot {
        Snapshot(isEnabled: isEnabled, amount: amount, currency: currency)
    }

    private let defaults: UserDefaults
    private let didChangeSubject = PassthroughSubject<Void, Never>()

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = defaults.bool(forKey: Keys.isEnabled)
        amount = defaults.string(forKey: Keys.amount)
            .flatMap { Decimal(string: $0, locale: Self.storageLocale) }
            .map(Self.sanitized) ?? 0
        currency = defaults.string(forKey: Keys.currency)
            .flatMap(Currency.init(rawValue:)) ?? .usd
    }

    public func setEnabled(_ isEnabled: Bool) {
        guard self.isEnabled != isEnabled else { return }
        self.isEnabled = isEnabled
        defaults.set(isEnabled, forKey: Keys.isEnabled)
        didChangeSubject.send(())
    }

    public func setAmount(_ amount: Decimal) {
        let amount = Self.sanitized(amount)
        guard self.amount != amount else { return }
        self.amount = amount
        defaults.set(NSDecimalNumber(decimal: amount).description(withLocale: Self.storageLocale), forKey: Keys.amount)
        didChangeSubject.send(())
    }

    public func setCurrency(_ currency: Currency) {
        guard self.currency != currency else { return }
        self.currency = currency
        defaults.set(currency.rawValue, forKey: Keys.currency)
        didChangeSubject.send(())
    }

    /// Parses user input such as `1 234,56`, `1,234.56` or `1234.5`.
    /// Returns `nil` for anything that is not a non-negative number.
    public static func parseAmount(_ text: String) -> Decimal? {
        var cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .filter { !$0.isWhitespace && $0 != "'" && $0 != "\u{00A0}" && $0 != "\u{202F}" }
        guard !cleaned.isEmpty else { return nil }

        // The right-most of `.`/`,` is the decimal separator; any others are grouping.
        if let separatorIndex = cleaned.lastIndex(where: { $0 == "." || $0 == "," }) {
            let integerPart = String(cleaned[..<separatorIndex].filter { $0 != "." && $0 != "," })
            let fractionPart = String(cleaned[cleaned.index(after: separatorIndex)...])
            cleaned = integerPart + "." + fractionPart
        }

        guard
            cleaned.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }),
            let value = Decimal(string: cleaned, locale: storageLocale),
            value >= 0
        else {
            return nil
        }
        return sanitized(value)
    }

    /// Clamps to `0...maximumAmount` and keeps two fraction digits.
    static func sanitized(_ value: Decimal) -> Decimal {
        let clamped = min(max(value, 0), maximumAmount)
        var input = clamped
        var rounded = Decimal()
        NSDecimalRound(&rounded, &input, 2, .down)
        return rounded
    }

    private static let storageLocale = Locale(identifier: "en_US_POSIX")

    private enum Keys {
        static let isEnabled = "tk.demoBalance.isEnabled"
        static let amount = "tk.demoBalance.amount"
        static let currency = "tk.demoBalance.currency"
    }
}
