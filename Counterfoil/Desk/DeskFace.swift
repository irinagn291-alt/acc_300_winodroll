import SwiftUI

/// Role: Desk. Locked hold ticket. Home is the mechanic: numeric rail, claim-check face, Stamp and Cut. Views call stampWant and cutCover.
struct DeskFace: View {
    var store: DeskStore
    @Binding var sheet: ClaimSheet?
    @Binding var commitPulse: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var inFlight = false
    @State private var showSpin = false
    @State private var showMark = false
    @State private var faultLine: String?
    @State private var noteLine: String?
    @State private var verbTask: Task<Void, Never>?
    @State private var spinTask: Task<Void, Never>?
    @State private var markTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            DeskChrome(sheet: $sheet)
            if store.desk.wants.isEmpty {
                DeskBlank(
                    warning: store.warning,
                    writeFailed: store.lastWriteError != nil,
                    onStamp: { sheet = .stamp },
                    onRetry: { run { await store.flush() } }
                )
            } else {
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DeskColor.background.ignoresSafeArea())
        .overlay { successMark }
        .onChange(of: commitPulse) { _, value in
            guard value > 0 else { return }
            withAnimation(DeskMotion.commit(reduce: reduceMotion)) {
                showMark = true
            }
            markTask?.cancel()
            markTask = Task {
                try? await Task.sleep(nanoseconds: 900_000_000)
                await MainActor.run {
                    withAnimation(DeskMotion.ease) {
                        showMark = false
                    }
                }
            }
        }
        .onDisappear {
            verbTask?.cancel()
            spinTask?.cancel()
            markTask?.cancel()
        }
        .alert("Hold refused", isPresented: faultPresented) {
            Button("OK", role: .cancel) { faultLine = nil }
        } message: {
            Text(faultLine ?? "Try again.")
        }
    }

    private var populated: some View {
        VStack(spacing: 0) {
            banners
            CutoutArt(resource: "ctf_HeaderDecor", maxHeight: DeskSpace.n(7))
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.bottom, DeskSpace.n(1))
            TimelineView(.periodic(from: .now, by: 1)) { context in
                ticketStack(now: context.date)
            }
        }
    }

    private var banners: some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            if let warning = store.warning {
                Text(warningLine(warning))
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
            }
            if store.lastWriteError != nil {
                HStack {
                    Text("The desk did not save.")
                        .font(DeskFont.caption)
                        .foregroundStyle(DeskColor.ink)
                    Spacer()
                    Button("Retry") { run { await store.flush() } }
                        .font(DeskFont.caption)
                        .frame(minHeight: DeskSpace.n(6))
                }
            }
            if let noteLine {
                Text(noteLine)
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
            }
        }
        .padding(.horizontal, DeskSpace.n(3))
        .padding(.bottom, DeskSpace.n(1))
    }

    private func ticketStack(now: Date) -> some View {
        let face = store.desk.faceWant ?? store.desk.blankWants.first ?? store.desk.wants.first
        let remaining = face?.remainingHours(at: now) ?? 0
        let computed = face?.ticket?.computedHours ?? 0
        let covers = store.desk.coveringIDs(at: now).count
        let coolingCount = store.desk.coolingWants.count
        let canRelease = store.desk.canRelease(at: now)
        let canCut = store.desk.fold == .cooling && coolingCount > 1
        return VStack(alignment: .leading, spacing: DeskSpace.n(2)) {
            HourRail(
                remainingHours: remaining,
                computedHours: computed,
                coverCount: covers,
                monthlyLimit: store.desk.rules.monthlyImpulseLimit
            )
            .padding(.horizontal, DeskSpace.n(3))

            ticketCard(face: face, coolingCount: coolingCount)

            reholdStrip
                .padding(.horizontal, DeskSpace.n(3))

            verbs(canRelease: canRelease, canCut: canCut)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.bottom, DeskSpace.n(2))
        }
    }

    private func ticketCard(face: WillCall?, coolingCount: Int) -> some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(2)) {
            if let face {
                ClaimFace(want: face)
            }
            Spacer(minLength: DeskSpace.n(2))
            HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(1)) {
                Text("Cooling on the desk")
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                    .lineLimit(1)
                Spacer(minLength: DeskSpace.n(1))
                Text(DeskFigures.count(Double(coolingCount)))
                    .font(DeskFont.headline)
                    .foregroundStyle(DeskColor.ink)
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
        .padding(DeskSpace.n(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous)
                .fill(DeskColor.surface)
        }
        .overlay {
            GeometryReader { geo in
                Image("ctf_CardBackdrop")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.18)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous))
        .deskRaised()
        .padding(.horizontal, DeskSpace.n(3))
    }

    private var reholdStrip: some View {
        Button {
            sheet = .rehold
        } label: {
            HStack(alignment: .center, spacing: DeskSpace.n(2)) {
                Image("ctf_ControlFace")
                    .resizable()
                    .scaledToFit()
                    .frame(width: DeskSpace.n(5), height: DeskSpace.n(5))
                    .clipped()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Same code keeps the longer span.")
                        .font(DeskFont.body)
                        .foregroundStyle(DeskColor.ink)
                        .multilineTextAlignment(.leading)
                    Text("Stamp another. Cut buys early.")
                        .font(DeskFont.caption)
                        .foregroundStyle(DeskColor.muted)
                }
                Spacer(minLength: DeskSpace.n(1))
                Image(systemName: "chevron.right")
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, DeskSpace.n(2))
            .frame(maxWidth: .infinity, minHeight: DeskSpace.n(6), alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous)
                            .fill(DeskColor.accent.opacity(0.12))
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous))
        }
        .buttonStyle(ChromePress())
        .deskRaised()
        .accessibilityLabel("Longer span rehold")
        .accessibilityHint("How stamping the same retail code keeps the longer wait.")
    }

    @ViewBuilder
    private func verbs(canRelease: Bool, canCut: Bool) -> some View {
        VStack(spacing: DeskSpace.n(1)) {
            Button("Stamp") { sheet = .stamp }
                .buttonStyle(StampPress())
                .disabled(inFlight)
                .accessibilityHint("File a want and stamp a hold ticket.")
            if canRelease {
                Button("Bought") { run { await release(.bought) } }
                    .buttonStyle(StampPress(isLoading: showSpin))
                    .disabled(inFlight)
                Button("Dropped") { run { await release(.dropped) } }
                    .buttonStyle(StampPress(kind: .cut, isLoading: showSpin))
                    .disabled(inFlight)
            } else {
                Button("Cut") { sheet = .cut }
                    .buttonStyle(StampPress(kind: .cut))
                    .disabled(inFlight || !canCut)
                    .accessibilityHint("Sacrifice another cooling ticket whose remaining hours cover this rail.")
            }
        }
    }

    @ViewBuilder
    private var successMark: some View {
        if showMark {
            Image("ctf_SuccessMark")
                .resizable()
                .scaledToFit()
                .frame(width: DeskSpace.n(12), height: DeskSpace.n(12))
                .clipped()
                .accessibilityHidden(true)
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
        }
    }

    private var faultPresented: Binding<Bool> {
        Binding(
            get: { faultLine != nil },
            set: { if !$0 { faultLine = nil } }
        )
    }

    private func release(_ fate: ClaimFate) async {
        do {
            try await store.releaseFace(fate: fate)
            noteLine = fate == .bought ? "Bought." : "Dropped."
        } catch let fault as DeskFault {
            faultLine = DeskCopy.fault(fault)
        } catch {
            faultLine = "Release failed."
        }
    }

    private func warningLine(_ warning: DeskWarning) -> String {
        switch warning {
        case .recoveredFromBackup: return "Restored the last good desk."
        case .startedEmpty: return "The desk file was unreadable."
        }
    }

    private func run(_ work: @escaping @MainActor () async -> Void) {
        inFlight = true
        spinTask?.cancel()
        spinTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if !Task.isCancelled {
                await MainActor.run { showSpin = true }
            }
        }
        verbTask = Task {
            await work()
            spinTask?.cancel()
            await MainActor.run {
                showSpin = false
                inFlight = false
            }
        }
    }
}
