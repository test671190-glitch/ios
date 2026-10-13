import TKUIKit
import UIKit

/// The "Demo mode" section of the root settings list.
///
/// Drives `DemoBalanceSettings` only. Nothing here touches wallets, keys, network or
/// transactions: the values are read back solely by `BalanceSwiftUIView` at render time,
/// which also draws the mandatory `DemoBalanceBadge` while the mode is on.
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
            id: .toggleItemIdentifier,
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
        let formatted = DemoBalanceDisplay.text(amount: settings.amount, currency: settings.currency)
        return SettingsListItem(
            id: .amountItemIdentifier,
            title: SettingsListItemTitle(DemoBalanceStrings.amountTitle),
            accessory: .text(
                SettingsListItemTextAccessory(
                    text: formatted,
                    color: .accentBlue,
                    textStyle: .label1
                )
            ),
            onTap: { anchorView in
                guard let presenter = anchorView?.demoBalancePresenter else { return }
                presentAmountAlert(from: presenter, settings: settings)
            }
        )
    }

    static func makeCurrencyItem(settings: DemoBalanceSettings) -> SettingsListItem {
        let selected = settings.currency
        return SettingsListItem(
            id: .currencyItemIdentifier,
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

        alert.addTextField { textField in
            textField.keyboardType = .decimalPad
            textField.placeholder = DemoBalanceStrings.amountAlertPlaceholder
            textField.text = settings.amount == 0 ? nil : DemoBalanceDisplay.editableText(amount: settings.amount)
            textField.clearButtonMode = .whileEditing
            textField.accessibilityIdentifier = "demo_balance_amount_field"
        }

        alert.addAction(UIAlertAction(title: DemoBalanceStrings.cancel, style: .cancel))
        alert.addAction(
            UIAlertAction(title: DemoBalanceStrings.save, style: .default) { [weak alert] _ in
                let text = alert?.textFields?.first?.text ?? ""
                // Empty field resets to zero; unparsable input leaves the value unchanged.
                let parsed: Decimal? = text.isEmpty ? Decimal.zero : DemoBalanceSettings.parseAmount(text)
                guard let amount = parsed else { return }
                settings.setAmount(amount)
            }
        )

        presenter.present(alert, animated: true)
    }
}

/// Plain-text rendering of the demo amount for the settings row and the edit field.
private enum DemoBalanceDisplay {
    static func text(amount: Decimal, currency: DemoBalanceSettings.Currency) -> String {
        let number = makeFormatter(grouping: true).string(from: NSDecimalNumber(decimal: amount)) ?? "0"
        return currency.isSymbolLeading
            ? "\(currency.symbol)\(number)"
            : "\(number) \(currency.symbol)"
    }

    static func editableText(amount: Decimal) -> String {
        makeFormatter(grouping: false).string(from: NSDecimalNumber(decimal: amount)) ?? ""
    }

    private static func makeFormatter(grouping: Bool) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = grouping
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        return formatter
    }
}

private extension UIView {
    /// The top-most view controller that can present over the screen this view is on.
    var demoBalancePresenter: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                var top = viewController
                while let presented = top.presentedViewController, !presented.isBeingDismissed {
                    top = presented
                }
                return top
            }
            responder = current.next
        }
        return window?.rootViewController
    }
}

private extension String {
    static let toggleItemIdentifier = "DemoBalanceToggleItem"
    static let amountItemIdentifier = "DemoBalanceAmountItem"
    static let currencyItemIdentifier = "DemoBalanceCurrencyItem"
}
