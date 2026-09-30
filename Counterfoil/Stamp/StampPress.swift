import SwiftUI

/// Role: Stamp. Full-width primary chrome. Default, pressed, disabled, loading. Cut uses the destructive variant. Accent is the live verb only.
struct StampPress: ButtonStyle {
    enum Kind {
        case stamp
        case cut
    }

    var kind: Kind = .stamp
    var isLoading: Bool = false

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .font(DeskFont.headline)
                .foregroundStyle(ink)
                .opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView()
                    .tint(ink)
            }
        }
        .frame(maxWidth: .infinity, minHeight: DeskSpace.n(6))
        .padding(.horizontal, DeskSpace.n(2))
        .background { plate(pressed: configuration.isPressed) }
        .contentShape(RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous))
        .scaleEffect(scale(pressed: configuration.isPressed))
        .opacity(isEnabled ? 1 : 0.55)
        .animation(reduceMotion ? nil : DeskMotion.ease, value: configuration.isPressed)
        .animation(DeskMotion.ease, value: isLoading)
    }

    private var ink: Color {
        isEnabled ? DeskColor.ink : DeskColor.muted
    }

    private func scale(pressed: Bool) -> CGFloat {
        if reduceMotion || !isEnabled || isLoading { return 1 }
        return pressed ? 0.98 : 1
    }

    @ViewBuilder
    private func plate(pressed: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous)
        shape
            .fill(.ultraThinMaterial)
            .overlay {
                shape.fill(tint(pressed: pressed))
            }
            .overlay {
                shape.stroke(DeskColor.muted.opacity(kind == .cut ? 0.45 : 0.2), lineWidth: DeskSpace.rule)
            }
            .deskRaised()
    }

    private func tint(pressed: Bool) -> Color {
        switch kind {
        case .stamp:
            let base: Double = isEnabled ? 0.30 : 0.08
            return DeskColor.accent.opacity(pressed ? min(base + 0.12, 0.5) : base)
        case .cut:
            let base: Double = isEnabled ? 0.55 : 0.2
            return DeskColor.surface.opacity(pressed ? min(base + 0.15, 0.8) : base)
        }
    }
}
