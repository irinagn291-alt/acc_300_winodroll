import SwiftUI

/// Role: Desk. One-shot three-page cover. Continue or Next at the bottom full width. Skip writes starter rules.
struct DeskBrief: View {
    var store: DeskStore
    var onFinished: () -> Void

    @State private var page = 0
    @State private var busy = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [(art: String, title: String, line: String)] = [
        ("ctf_Onboarding1", "Hold the purchase.", "Stamp a priced want and wait the hours."),
        ("ctf_Onboarding2", "The rail ticks hours.", "Price, priority, necessity, and discretion set the span."),
        ("ctf_Onboarding3", "Same code keeps longer.", "Cut early only by dropping another cooling ticket.")
    ]

    var body: some View {
        let item = pages[page]
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                    .frame(minWidth: DeskSpace.n(6), minHeight: DeskSpace.n(6))
                    .padding(.horizontal, DeskSpace.n(3))
                    .contentShape(Rectangle())
                    .disabled(busy)
            }
            CutoutArt(resource: item.art)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text(item.title)
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(2))
            Text(item.line)
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
            Text("Page \(page + 1) of \(pages.count)")
                .font(DeskFont.micro)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(2))
            Button(page == pages.count - 1 ? "Next" : "Continue") {
                if page == pages.count - 1 {
                    finish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(StampPress(isLoading: busy))
            .disabled(busy)
            .padding(.horizontal, DeskSpace.n(3))
            .padding(.vertical, DeskSpace.n(3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DeskColor.background.ignoresSafeArea())
        .animation(reduceMotion ? Animation.easeOut(duration: 0.2) : DeskMotion.ease, value: page)
    }

    private func finish() {
        busy = true
        Task {
            await store.setOnboardingComplete(true)
            await store.flush()
            busy = false
            onFinished()
        }
    }
}
