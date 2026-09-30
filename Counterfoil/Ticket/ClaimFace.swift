import SwiftUI

/// Role: Ticket. Claim-check face under the hour rail. Hold word plus symbol. Not a list of wants.
struct ClaimFace: View {
    let want: WillCall

    var body: some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            Text(want.name)
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.ink)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(DeskFigures.money(want.price))
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.ink)
                .monospacedDigit()
                .lineLimit(1)
            HStack(spacing: DeskSpace.n(1)) {
                Image(systemName: DeskCopy.holdSymbol(want.hold, fate: want.fate))
                    .font(DeskFont.caption)
                    .accessibilityHidden(true)
                Text(DeskCopy.hold(want.hold, fate: want.fate))
                    .font(DeskFont.caption)
            }
            .foregroundStyle(DeskColor.muted)
            .padding(.horizontal, DeskSpace.n(2))
            .frame(minHeight: DeskSpace.n(4))
            .background {
                RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous)
                    .fill(DeskColor.background.opacity(0.55))
            }
            if let code = want.normalizedCode {
                Text(code)
                    .font(DeskFont.micro)
                    .foregroundStyle(DeskColor.muted)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
