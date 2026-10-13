import Foundation

/// Texts for the demo-balance mode. Russian when the app runs in Russian, English otherwise.
/// Kept out of the generated `TKLocales` so the fork does not touch the shared string tables.
public enum DemoBalanceStrings {
    public static var badge: String {
        isRussian ? "DEMO · не реальный баланс" : "DEMO · not a real balance"
    }

    public static var sectionTitle: String {
        isRussian ? "Демо-режим" : "Demo mode"
    }

    public static var toggleTitle: String {
        isRussian ? "Демо-баланс" : "Demo balance"
    }

    public static var toggleCaption: String {
        isRussian
            ? "Меняет только цифру на главном экране"
            : "Changes only the number on the main screen"
    }

    public static var amountTitle: String {
        isRussian ? "Сумма" : "Amount"
    }

    public static var currencyTitle: String {
        isRussian ? "Валюта" : "Currency"
    }

    public static var sectionFooter: String {
        isRussian
            ? "Демо-баланс хранится только на этом устройстве и ничем не обеспечен: его нельзя отправить, обменять или использовать. Реальный баланс, отправка и история работают как обычно. Пока режим включён, над балансом всегда видна плашка DEMO."
            : "The demo balance is stored on this device only and is not backed by anything: it cannot be sent, swapped or used. Your real balance, sending and history work as usual. While the mode is on, a DEMO badge is always shown above the balance."
    }

    public static var amountAlertTitle: String {
        isRussian ? "Демо-баланс" : "Demo balance"
    }

    public static var amountAlertMessage: String {
        isRussian
            ? "Сумма только для отображения. Её нельзя потратить."
            : "Display-only amount. It cannot be spent."
    }

    public static var amountAlertPlaceholder: String {
        "0.00"
    }

    public static var save: String {
        isRussian ? "Сохранить" : "Save"
    }

    public static var cancel: String {
        isRussian ? "Отмена" : "Cancel"
    }

    public static func accessibilityAmount(_ amount: String) -> String {
        isRussian
            ? "Демо-баланс, не реальный: \(amount)"
            : "Demo balance, not real: \(amount)"
    }

    private static var isRussian: Bool {
        let language = Bundle.main.preferredLocalizations.first
            ?? Locale.preferredLanguages.first
            ?? "en"
        return language.hasPrefix("ru")
    }
}
