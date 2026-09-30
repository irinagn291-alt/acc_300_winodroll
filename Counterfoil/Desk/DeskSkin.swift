import SwiftUI

/// Role: Desk. One spring on a successful Stamp or CoverMark. Everything else ease-out. Reduce Motion fades only.
enum DeskMotion {
    static let ease = Animation.easeOut(duration: 0.25)
    static let commitSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)

    static func commit(reduce: Bool) -> Animation {
        reduce ? Animation.easeOut(duration: 0.2) : commitSpring
    }
}

/// Role: Desk. Single soft drop-shadow. Reused wherever a surface sits above the desk.
enum DeskLift {
    static let color = DeskColor.ink.opacity(0.18)
    static let radius = DeskSpace.n(2)
    static let y = DeskSpace.n(1)
}

struct DeskRaise: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: DeskLift.color, radius: DeskLift.radius, x: 0, y: DeskLift.y)
    }
}

extension View {
    func deskRaised() -> some View {
        modifier(DeskRaise())
    }

    func claimSheetChrome() -> some View {
        presentationCornerRadius(DeskRadius.card)
            .presentationBackground(DeskColor.background)
            .presentationDragIndicator(.visible)
            .scrollDismissesKeyboard(.interactively)
    }

    func deskRowSurface() -> some View {
        listRowBackground(
            RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous)
                .fill(DeskColor.surface)
                .deskRaised()
                .padding(.vertical, DeskSpace.n(1))
        )
    }
}

/// Role: Desk. Icon-only close. 44 pt hit. VoiceOver names Close.
struct DeskClose: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.ink)
                .frame(minWidth: DeskSpace.n(6), minHeight: DeskSpace.n(6))
                .contentShape(Rectangle())
        }
        .buttonStyle(ChromePress())
        .accessibilityLabel("Close")
    }
}

/// Role: Desk. Generated cutout art. Decorative, never the brand as an SF Symbol.
struct CutoutArt: View {
    let resource: String
    var maxHeight: CGFloat? = nil

    var body: some View {
        Image(resource)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .clipped()
            .accessibilityHidden(true)
    }
}

/// Role: Desk. Pressed opacity for chrome that is not the Stamp verb.
struct ChromePress: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(opacity(pressed: configuration.isPressed))
            .animation(reduceMotion ? nil : DeskMotion.ease, value: configuration.isPressed)
    }

    private func opacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.45 }
        return pressed ? 0.7 : 1
    }
}
