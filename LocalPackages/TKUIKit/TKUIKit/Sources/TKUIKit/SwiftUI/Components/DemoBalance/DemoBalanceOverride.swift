import Foundation

/// Swaps the displayed amount of a balance header for the demo amount.
///
/// Pure function over a view config: it only changes what is drawn. Everything else in the
/// config (address row, battery, backup warning, secure mode) is kept as the real wallet
/// produced it, and nothing is written anywhere.
public extension BalanceViewConfig {
    func applyingDemoBalance(_ demo: DemoBalanceSettings.Snapshot) -> BalanceViewConfig {
        guard demo.isEnabled, case var .content(content) = self else {
            return self
        }
        content.balance = content.balance.applyingDemoBalance(demo)
        return .content(content)
    }

    /// `true` when the header is showing content in demo mode, i.e. when the badge must be drawn.
    func showsDemoBadge(_ demo: DemoBalanceSettings.Snapshot) -> Bool {
        guard demo.isEnabled, case .content = self else { return false }
        return true
    }
}

extension BalanceViewContent.Balance {
    func applyingDemoBalance(_ demo: DemoBalanceSettings.Snapshot) -> BalanceViewContent.Balance {
        switch state {
        case .secure:
            // Hidden-balance mode stays hidden; the badge still marks the header as demo.
            return self
        case let .amount(real):
            let formatted = DemoBalanceFormatter.format(amount: demo.amount, currency: demo.currency)
            return BalanceViewContent.Balance(
                amount: BalanceViewContent.Balance.Amount(
                    leadingText: formatted.leadingText,
                    trailingText: formatted.trailingText,
                    textParts: formatted.textParts,
                    textSize: formatted.textSize,
                    tooltipText: nil,
                    accessibilityText: DemoBalanceStrings.accessibilityAmount(formatted.fullText),
                    color: real.color
                )
            )
        }
    }
}

/// Formats the demo amount the way the real header does: a large integer part followed by a
/// smaller two-digit fraction, with the currency symbol on the side its locale expects.
enum DemoBalanceFormatter {
    struct Output {
        let leadingText: String?
        let trailingText: String?
        let textParts: [BalanceViewContent.Balance.Amount.TextPart]
        let textSize: BalanceViewContent.Balance.Amount.TextSize
        let fullText: String
    }

    /// Integer digits from which the header switches to the reduced font, like the real header.
    private static let reducedTextDigitThreshold = 9

    static func format(
        amount: Decimal,
        currency: DemoBalanceSettings.Currency,
        locale: Locale = .current
    ) -> Output {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down

        let decimalSeparator = formatter.decimalSeparator ?? "."
        let number = formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "0\(decimalSeparator)00"

        let textParts: [BalanceViewContent.Balance.Amount.TextPart]
        if let separatorRange = number.range(of: decimalSeparator, options: .backwards) {
            let integer = String(number[..<separatorRange.upperBound])
            let fraction = String(number[separatorRange.upperBound...])
            textParts = [
                .init(text: integer, role: .primary),
                .init(text: fraction, role: .fraction),
            ]
        } else {
            textParts = [.init(text: number, role: .primary)]
        }

        let integerDigitCount = NSDecimalNumber(decimal: amount)
            .int64Value
            .magnitude
            .description
            .count
        let textSize: BalanceViewContent.Balance.Amount.TextSize =
            integerDigitCount >= reducedTextDigitThreshold ? .reduced : .regular

        let leadingText = currency.isSymbolLeading ? currency.symbol : nil
        let trailingText = currency.isSymbolLeading ? nil : currency.symbol
        let fullText = [leadingText, number, trailingText]
            .compactMap { $0 }
            .joined(separator: currency.isSymbolLeading ? "" : " ")

        return Output(
            leadingText: leadingText,
            trailingText: trailingText,
            textParts: textParts,
            textSize: textSize,
            fullText: fullText
        )
    }
}
