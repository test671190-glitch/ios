import TKUIKit
import UIKit

/// The "Demo mode" section of the root settings list.
///
/// Drives `DemoBalanceSettings` only. Nothing here touches wallets, keys, network or
/// transactions: the values are read back solely by `BalanceSwiftUIView` at render time.
enum SettingsListDemoBalanceSection {
    static func make(settings: DemoBalanceSettings = .shared) -> SettingsListSection {
        var items: [SettingsListItemsSectionItem] = [.listItem(makeToggleItem(settings: settings))]
        if settings.isEnabled {
            items.append(.listItem(makeAmountItem(settings: settings)))
            items.append(.listItem(makeCurrencyItem(settings: settings)))
        }
        return .items(
            SettingsListItemsSection(
                items: items,
                header: SettingsListSectionHeader(title: DemoBalanceStrings.sectionTitle),
                footer: DemoBalanceStrings.sectionFooter
            )
        )
    }
}

private extension SettingsListDemoBalanceSection {
    static func makeToggleItem(settings: DemoBalanceSettings) -> SettingsListItem {
        SettingsListItem(
            id: .demoBalanceToggleItemIdentifier,
            title: SettingsListItemTitle(DemoBalanceStrings.toggleTitle),
            tags: [.tag(text: "DEMO")],
            captions: [SettingsListItemCaption(DemoBalanceStrings.toggleCaption)],
            accessory: .toggle(
                SettingsListItemToggleAccessory(isOn: settings.isEnabled) { isOn in
                    settings.setEnabled(isOn)
                }
            )
        )
    }

    static func makeAmountItem(settings: DemoBalanceSettings) -> SettingsListItem {
        SettingsListItem(
            id: .demoBalanceAmountItemIdentifier,
            title: SettingsListItemTitle(DemoBalanceStrings.amountTitle),
            accessory: .text(
                SettingsListItemTextAccessory(
                    text: DemoBalanceDisplay.text(amount: settings.amount, currency: settings.currency),
                    color: .accentBlue,
                    textStyle: .label1
                )
            ),
            onTap: { anchorView in
                // Present from the top-most modal of the window, like
                // `modalPresentationSourceViewController()`; skip while another alert is up
                // (e.g. a quick double tap) or a modal is still animating away.
                guard
                    let presenter = anchorView?.window?.rootViewController?.topPresentedViewController(),
                    !presenter.isBeingDismissed,
                    !(presenter is UIAlertController)
                else {
                    return
                }
                presentAmountAlert(from: presenter, settings: settings)
            }
        )
    }

    static func makeCurrencyItem(settings: DemoBalanceSettings) -> SettingsListItem {
        let selected = settings.currency
        return SettingsListItem(
            id: .demoBalanceCurrencyItemIdentifier,
            title: SettingsListItemTitle(DemoBalanceStrings.currencyTitle),
            accessory: .menu(
                SettingsListItemMenuAccessory(
                    label: SettingsListItemTextAccessory(
                        text: selected.code,
                        color: .accentBlue,
                        textStyle: .label1
                    ),
                    options: DemoBalanceSettings.Currency.allCases.map { currency in
                        SettingsListItemMenuOption(
                            title: currency.code,
                            isSelected: currency == selected,
                            action: { settings.setCurrency(currency) }
                        )
                    }
                )
            )
        )
    }

    @MainActor
    static func presentAmountAlert(from presenter: UIViewController, settings: DemoBalanceSettings) {
        let alert = UIAlertController(
            title: DemoBalanceStrings.amountAlertTitle,
            message: DemoBalanceStrings.amountAlertMessage,
            preferredStyle: .alert
        )

        let saveAction = UIAlertAction(title: DemoBalanceStrings.save, style: .default) { [weak alert] _ in
            // Save is disabled while the input is invalid; this guard only covers races.
            let text = alert?.textFields?.first?.text ?? ""
            guard let amount = DemoBalanceDisplay.amount(fromInput: text) else { return }
            settings.setAmount(amount)
        }

        alert.addTextField { textField in
            textField.keyboardType = .decimalPad
            textField.placeholder = DemoBalanceStrings.amountAlertPlaceholder
            textField.text = settings.amount == 0 ? nil : DemoBalanceDisplay.editableText(amount: settings.amount)
            textField.clearButtonMode = .whileEditing
            textField.accessibilityIdentifier = "demo_balance_amount_field"
            // An empty field resets to zero; unparsable input disables Save instead of being
            // silently dropped when the alert closes.
            textField.addAction(
                UIAction(handler: { [weak textField, weak saveAction] _ in
                    let text = textField?.text ?? ""
                    saveAction?.isEnabled = DemoBalanceDisplay.amount(fromInput: text) != nil
                }),
                for: .editingChanged
            )
        }

        alert.addAction(UIAlertAction(title: DemoBalanceStrings.cancel, style: .cancel))
        alert.addAction(saveAction)
        alert.preferredAction = saveAction

        presenter.present(alert, animated: true)
    }
}

/// Plain-text rendering of the demo amount for the settings row and the edit field.
private enum DemoBalanceDisplay {
    /// Same shape as the header: grouped, two fraction digits, symbol on its usual side.
    static func text(amount: Decimal, currency: DemoBalanceSettings.Currency) -> String {
        let number = displayFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "0"
        return currency.isSymbolLeading
            ? "\(currency.symbol)\(number)"
            : "\(number) \(currency.symbol)"
    }

    /// ASCII digits without grouping, using the locale's decimal separator when it is `,`
    /// (`1234,5` in ru_RU, `1234.5` in en_US). Always round-trips through
    /// `DemoBalanceSettings.parseAmount`, unlike a locale `NumberFormatter`, which may emit
    /// non-ASCII digits or separators in some regions.
    static func editableText(amount: Decimal) -> String {
        let plain = NSDecimalNumber(decimal: amount).description(withLocale: posixLocale)
        guard Locale.autoupdatingCurrent.decimalSeparator == "," else { return plain }
        return plain.replacingOccurrences(of: ".", with: ",")
    }

    /// `0` for an empty field, the parsed value for valid input, `nil` for anything else.
    static func amount(fromInput text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? 0 : DemoBalanceSettings.parseAmount(trimmed)
    }

    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    private static let displayFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        return formatter
    }()
}

private extension String {
    static let demoBalanceToggleItemIdentifier = "DemoBalanceToggleItem"
    static let demoBalanceAmountItemIdentifier = "DemoBalanceAmountItem"
    static let demoBalanceCurrencyItemIdentifier = "DemoBalanceCurrencyItem"
}
