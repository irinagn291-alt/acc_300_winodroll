import SwiftUI

/// Role: Desk. Asymmetric chrome for Review, Rules, and Settings. The hold ticket never leaves.
struct DeskChrome: View {
    @Binding var sheet: ClaimSheet?

    var body: some View {
        HStack(spacing: DeskSpace.n(1)) {
            chrome("Review", symbol: "list.bullet.rectangle", opens: .review)
            Spacer(minLength: DeskSpace.n(1))
            chrome("Rules", symbol: "slider.horizontal.3", opens: .rules)
            chrome("Settings", symbol: "gearshape", opens: .settings)
        }
        .padding(.horizontal, DeskSpace.n(3))
        .padding(.vertical, DeskSpace.n(1))
    }

    private func chrome(_ title: String, symbol: String, opens: ClaimSheet) -> some View {
        Button {
            sheet = opens
        } label: {
            HStack(spacing: DeskSpace.n(1)) {
                Image(systemName: symbol)
                    .font(DeskFont.caption)
                    .accessibilityHidden(true)
                Text(title)
                    .font(DeskFont.caption)
            }
            .foregroundStyle(DeskColor.ink)
            .padding(.horizontal, DeskSpace.n(2))
            .frame(minHeight: DeskSpace.n(6))
            .background {
                RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous)
                    .fill(DeskColor.surface)
            }
            .contentShape(RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous))
        }
        .buttonStyle(ChromePress())
        .accessibilityLabel(title)
    }
}
