import SwiftUI

/// Role: Desk. Root. Onboarding cover, then the locked hold ticket. ReviewScreen keys present sheets after onboarding.
struct ContentView: View {
    var store: DeskStore

    @Environment(\.scenePhase) private var scenePhase
    @State private var sheet: ClaimSheet?
    @State private var ready = false
    @State private var hookConsumed = false
    @State private var commitPulse = 0

    var body: some View {
        Group {
            if !ready {
                DeskColor.background.ignoresSafeArea()
            } else if !store.desk.onboardingComplete {
                DeskBrief(store: store) {
                    applyHook()
                }
            } else {
                DeskFace(store: store, sheet: $sheet, commitPulse: $commitPulse)
            }
        }
        .background(DeskColor.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .tint(DeskColor.accent)
        .task { await boot() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive || phase == .background {
                Task { await store.flush() }
            }
        }
        .onChange(of: store.desk.onboardingComplete) { _, done in
            if done {
                applyHook()
            } else {
                sheet = nil
            }
        }
        .sheet(item: $sheet) { item in
            sheetView(item)
                .claimSheetChrome()
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.85), trigger: commitPulse)
    }

    @ViewBuilder
    private func sheetView(_ item: ClaimSheet) -> some View {
        switch item {
        case .review:
            ClaimReview(store: store, onClose: { sheet = nil })
        case .rules:
            DeskRules(store: store)
        case .settings:
            DeskSettings(store: store, onClose: { sheet = nil })
        case .stamp:
            StampSheet(
                store: store,
                onStamped: {
                    sheet = nil
                    commitFromStamp()
                },
                onClose: { sheet = nil }
            )
        case .cut:
            CutSheet(
                store: store,
                onCovered: {
                    sheet = nil
                    commitFromStamp()
                },
                onShort: {},
                onClose: { sheet = nil }
            )
        case .rehold:
            ReholdSheet(store: store, onClose: { sheet = nil })
        }
    }

    private func boot() async {
        await store.load()
        await store.seedDemoIfNeeded()
        ready = true
        applyHook()
    }

    private func applyHook() {
        var consumed = hookConsumed
        let hook = DeskLaunch.consume(
            onboardingComplete: store.desk.onboardingComplete,
            consumed: &consumed
        )
        hookConsumed = consumed
        if let hook, let next = ClaimSheet.from(hook: hook) {
            sheet = next
        }
    }

    private func commitFromStamp() {
        commitPulse += 1
    }
}

#Preview {
    ContentView(store: DeskStore())
}
