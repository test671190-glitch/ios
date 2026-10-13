import SwiftUI

/// The "DEMO · not a real balance" plate drawn over the balance header while demo mode is on.
///
/// This is a hard requirement of the demo mode, not a style option: whenever the header shows
/// a demo amount, this badge is visible, so a screenshot of the screen cannot pass for a real
/// balance. There is intentionally no flag, setting or parameter that hides it.
public struct DemoBalanceBadge: View {
    @Environment(\.tkPalette) private var palette

    public init() {}

    public var body: some View {
        HStack(spacing: Layout.iconSpacing) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: Layout.iconSize, weight: .bold))

            Text(DemoBalanceStrings.badge)
                .font(Font(TKTextStyle.label3.font))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .foregroundStyle(TKColor.constantWhite.resolve(palette))
        .padding(.horizontal, Layout.horizontalPadding)
        .frame(height: Layout.height)
        .background(
            Capsule(style: .continuous)
                .fill(TKColor.accentOrange.resolve(palette))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DemoBalanceStrings.badge)
        .accessibilityIdentifier("demo_balance_badge")
        // Purely informational: taps fall through to the header underneath.
        .allowsHitTesting(false)
    }
}

public extension DemoBalanceBadge {
    /// Height the header reserves above the amount for the badge.
    static let height: CGFloat = Layout.height
}

private extension DemoBalanceBadge {
    enum Layout {
        static let height: CGFloat = 22
        static let horizontalPadding: CGFloat = 10
        static let iconSize: CGFloat = 10
        static let iconSpacing: CGFloat = 4
    }
}
