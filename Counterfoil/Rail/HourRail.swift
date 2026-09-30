import SwiftUI

/// Role: Rail. TimelineView numeric rail of remaining hours. Canvas and Shape stay on this Desk hero only.
struct HourRail: View {
    let remainingHours: Double
    let computedHours: Double
    let coverCount: Int
    let monthlyLimit: Double

    @Environment(\.dynamicTypeSize) private var typeSize

    private var fraction: CGFloat {
        guard computedHours > 0 else { return 0 }
        return CGFloat(min(max(remainingHours / computedHours, 0), 1))
    }

    private var railFont: Font {
        if typeSize >= .accessibility1 {
            return DeskFont.headline
        }
        if typeSize >= .xxLarge {
            return DeskFont.title
        }
        return DeskFont.display
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            Text("Hold this purchase.")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
                .lineLimit(2)
            Text(DeskFigures.hours(remainingHours))
                .font(railFont)
                .foregroundStyle(DeskColor.accent)
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("hours left")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
            Rectangle()
                .fill(DeskColor.muted.opacity(0.45))
                .frame(height: DeskSpace.rule)
                .accessibilityHidden(true)
            figures
            railCanvas
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessLabel)
    }

    private var figures: some View {
        HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(2)) {
            figure(DeskFigures.hours(computedHours), caption: "stamped")
            Spacer(minLength: DeskSpace.n(1))
            figure(DeskFigures.count(Double(coverCount)), caption: "covers")
            Spacer(minLength: DeskSpace.n(1))
            figure(DeskFigures.money(monthlyLimit), caption: "limit")
        }
    }

    private func figure(_ value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(DeskFont.headline)
                .foregroundStyle(DeskColor.ink)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(caption)
                .font(DeskFont.micro)
                .foregroundStyle(DeskColor.muted)
        }
    }

    private var railCanvas: some View {
        Canvas { context, size in
            let track = Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: DeskRadius.chip)
            context.fill(track, with: .color(DeskColor.surface))
            let width = max(0, size.width * fraction)
            if width > 0 {
                let fillRect = CGRect(x: 0, y: 0, width: width, height: size.height)
                let fill = Path(roundedRect: fillRect, cornerRadius: DeskRadius.chip)
                context.fill(fill, with: .color(DeskColor.accent))
            }
        }
        .frame(height: DeskSpace.n(2))
        .accessibilityHidden(true)
    }

    private var accessLabel: String {
        let left = DeskFigures.hours(remainingHours)
        let stamped = DeskFigures.hours(computedHours)
        let covers = DeskFigures.count(Double(coverCount))
        let limit = DeskFigures.money(monthlyLimit)
        return "Hold this purchase. \(left) hours left. \(stamped) stamped. \(covers) covers. Limit \(limit)."
    }
}
