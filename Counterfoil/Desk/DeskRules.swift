import SwiftUI

/// Role: Desk. Rules sheet. Edits the monthly impulse limit and fills leftover height with that limit's hours on the live cooling tickets and the next stamp. Empty, populated, error.
struct DeskRules: View {
    var store: DeskStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var limitText = ""
    @State private var originalText = ""
    @State private var busy = false
    @State private var showSpin = false
    @State private var note: String?
    @State private var confirmDiscard = false
    @State private var saveTask: Task<Void, Never>?
    @State private var spinTask: Task<Void, Never>?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            Group {
                if store.lastWriteError != nil && !store.desk.onboardingComplete {
                    errorPage
                } else {
                    populated
                }
            }
            .background(DeskColor.background)
            .navigationTitle("Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DeskColor.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DeskClose(action: attemptClose)
                        .disabled(busy)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                        .frame(minHeight: DeskSpace.n(6))
                }
            }
            .onAppear {
                if limitText.isEmpty {
                    let seeded = DeskFigures.ratio(store.desk.rules.monthlyImpulseLimit)
                    limitText = seeded
                    originalText = seeded
                }
            }
            .onDisappear {
                saveTask?.cancel()
                spinTask?.cancel()
            }
            .confirmationDialog("Discard the limit?", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("The new limit is not saved.")
            }
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let note {
                Text(note)
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DeskSpace.n(3))
                    .padding(.top, DeskSpace.n(1))
            }
            limitBlock
            GeometryReader { geo in
                ScrollView {
                    hoursBoard(canvas: geo.size)
                }
                .scrollDismissesKeyboard(.immediately)
                .scrollBounceBehavior(.basedOnSize)
            }
            .padding(.horizontal, DeskSpace.n(3))
            .padding(.top, DeskSpace.n(2))
            .clipped()
            saveBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DeskColor.background)
    }

    private var limitBlock: some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            Text("Monthly limit")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
            TextField("Monthly impulse limit", text: $limitText)
                .keyboardType(.decimalPad)
                .focused($focused)
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.ink)
                .monospacedDigit()
                .padding(.horizontal, DeskSpace.n(2))
                .frame(minHeight: DeskSpace.n(6), alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: DeskRadius.chip, style: .continuous)
                        .fill(DeskColor.surface)
                }
                .accessibilityLabel("Monthly impulse limit")
            Text("Hours come from price versus this limit. Local only. No checkout.")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
        }
        .padding(.horizontal, DeskSpace.n(3))
        .padding(.top, DeskSpace.n(2))
    }

    @ViewBuilder
    private func hoursBoard(canvas: CGSize) -> some View {
        if let parsedLimit {
            if store.desk.coolingWants.isEmpty && store.desk.blankWants.isEmpty {
                emptyHours(limit: parsedLimit, minHeight: canvas.height)
            } else {
                liveHours(limit: parsedLimit, now: Date(), canvas: canvas)
            }
        } else if limitText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messageCanvas(
                headline: "Set a monthly limit.",
                line: "Hours on the next stamp come from price versus this figure.",
                minHeight: canvas.height
            )
        } else {
            messageCanvas(
                headline: "Limit must be above zero.",
                line: "The live hours stay on the rail until a real limit is set.",
                minHeight: canvas.height
            )
        }
    }

    private func liveHours(limit: Double, now: Date, canvas: CGSize) -> some View {
        let cooling = store.desk.coolingWants
        let blanks = store.desk.blankWants
        let face = cooling.first(where: { $0.id == focusWant?.id }) ?? cooling.first ?? blanks.first
        let restCooling = cooling.filter { $0.id != face?.id }
        let restBlanks = blanks.filter { $0.id != face?.id }
        let wide = canvas.width >= DeskSpace.n(58)
        return VStack(alignment: .leading, spacing: DeskSpace.n(2)) {
            if wide, let face, face.hold == .cooling {
                HStack(alignment: .top, spacing: DeskSpace.n(3)) {
                    heroBand(face, limit: limit, now: now)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    logColumn(
                        cooling: restCooling,
                        blanks: blanks,
                        limit: limit,
                        now: now,
                        expands: restCooling.isEmpty
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            } else if let face, face.hold == .cooling {
                heroBand(face, limit: limit, now: now)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                logColumn(
                    cooling: restCooling,
                    blanks: blanks,
                    limit: limit,
                    now: now,
                    expands: false
                )
            } else if let face {
                nextStampHero(face, limit: limit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                logColumn(
                    cooling: [],
                    blanks: restBlanks,
                    limit: limit,
                    now: now,
                    expands: false
                )
            }
        }
        .padding(DeskSpace.n(3))
        .frame(minWidth: canvas.width, minHeight: canvas.height, alignment: .topLeading)
        .background { hoursPlate }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous))
        .deskRaised()
        .accessibilityElement(children: .contain)
    }

    private func heroBand(_ want: WillCall, limit: Double, now: Date) -> some View {
        let remaining = want.remainingHours(at: now)
        let atLimit = hours(for: want, limit: limit)
        let stamped = want.ticket?.computedHours ?? atLimit
        let saved = hours(for: want, limit: store.desk.rules.monthlyImpulseLimit)
        return VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            Text("Hours at this limit")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
            Text(want.name)
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.ink)
                .lineLimit(1)
            Text(DeskFigures.hours(atLimit))
                .font(heroFont)
                .foregroundStyle(DeskColor.accent)
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            Text("hours this limit stamps")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(2)) {
                figure(DeskFigures.hours(atLimit), caption: "this limit")
                Spacer(minLength: DeskSpace.n(1))
                figure(DeskFigures.hours(saved), caption: "saved")
                Spacer(minLength: DeskSpace.n(1))
                figure(DeskFigures.hours(remaining), caption: "on the rail")
            }
            Text(DeskFigures.money(want.price))
                .font(DeskFont.micro)
                .foregroundStyle(DeskColor.muted)
                .monospacedDigit()
                .lineLimit(1)
            Text(DeskCopy.limitShift(draft: limit, saved: store.desk.rules.monthlyImpulseLimit))
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: DeskSpace.n(16), alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(want.name). \(DeskFigures.hours(atLimit)) hours this limit stamps. \(DeskFigures.hours(saved)) saved. \(DeskFigures.hours(remaining)) on the rail. \(DeskFigures.hours(stamped)) stamped."
        )
    }

    private func nextStampHero(_ want: WillCall, limit: Double) -> some View {
        let atLimit = hours(for: want, limit: limit)
        let saved = hours(for: want, limit: store.desk.rules.monthlyImpulseLimit)
        return VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            Text("Hours at this limit")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
            Text(want.name)
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.ink)
                .lineLimit(1)
            Text(DeskFigures.hours(atLimit))
                .font(heroFont)
                .foregroundStyle(DeskColor.accent)
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            Text("hours this limit stamps")
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(2)) {
                figure(DeskFigures.hours(atLimit), caption: "this limit")
                Spacer(minLength: DeskSpace.n(1))
                figure(DeskFigures.hours(saved), caption: "saved")
                Spacer(minLength: DeskSpace.n(1))
                figure(DeskFigures.money(want.price), caption: "price")
            }
            Text(DeskCopy.limitShift(draft: limit, saved: store.desk.rules.monthlyImpulseLimit))
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: DeskSpace.n(16), alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(want.name). \(DeskFigures.hours(atLimit)) hours this limit stamps."
        )
    }

    private func logColumn(
        cooling: [WillCall],
        blanks: [WillCall],
        limit: Double,
        now: Date,
        expands: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(2)) {
            ForEach(cooling) { want in
                if want.id != cooling.first?.id {
                    hairline
                }
                coolingRow(want, limit: limit, now: now)
            }
            if !blanks.isEmpty {
                if !cooling.isEmpty {
                    hairline
                }
                Text("Next stamp")
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                ForEach(blanks) { want in
                    nextStampBand(want, limit: limit)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: expands ? .infinity : nil,
                            alignment: .leading
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func coolingRow(_ want: WillCall, limit: Double, now: Date) -> some View {
        let remaining = want.remainingHours(at: now)
        let atLimit = hours(for: want, limit: limit)
        return HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(1)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(want.name)
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .lineLimit(1)
                Text("On the rail \(DeskFigures.hours(remaining))")
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 0) {
                Text(DeskFigures.hours(atLimit))
                    .font(DeskFont.headline)
                    .foregroundStyle(DeskColor.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("this limit")
                    .font(DeskFont.micro)
                    .foregroundStyle(DeskColor.muted)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: DeskSpace.n(6), alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(want.name). \(DeskFigures.hours(atLimit)) hours at this limit. \(DeskFigures.hours(remaining)) on the rail."
        )
    }

    private func nextStampBand(_ want: WillCall, limit: Double) -> some View {
        let atLimit = hours(for: want, limit: limit)
        return HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(1)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(want.name)
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .lineLimit(1)
                Text("Hours this limit stamps")
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 0) {
                Text(DeskFigures.hours(atLimit))
                    .font(DeskFont.headline)
                    .foregroundStyle(DeskColor.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(DeskFigures.money(want.price))
                    .font(DeskFont.micro)
                    .foregroundStyle(DeskColor.muted)
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: DeskSpace.n(6), alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(want.name). \(DeskFigures.hours(atLimit)) hours this limit stamps."
        )
    }

    private func emptyHours(limit: Double, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.bottom, DeskSpace.n(2))
            Text("No cooling hours.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("This limit sets the next stamp. Price versus \(DeskFigures.money(limit)).")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DeskSpace.n(1))
        }
        .padding(DeskSpace.n(3))
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background { hoursPlate }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous))
        .deskRaised()
    }

    private func messageCanvas(headline: String, line: String, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.bottom, DeskSpace.n(2))
            Text(headline)
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(line)
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DeskSpace.n(1))
        }
        .padding(DeskSpace.n(3))
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background { hoursPlate }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous))
        .deskRaised()
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
                .lineLimit(1)
        }
    }

    private var hairline: some View {
        DeskColor.muted.opacity(0.45)
            .frame(height: DeskSpace.rule)
            .accessibilityHidden(true)
    }

    private var hoursPlate: some View {
        RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous)
            .fill(DeskColor.surface)
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
                .clipShape(RoundedRectangle(cornerRadius: DeskRadius.card, style: .continuous))
            }
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            hairline
            Button("Save") { save() }
                .buttonStyle(StampPress(isLoading: showSpin))
                .disabled(busy || parsedLimit == nil)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(2))
                .padding(.bottom, DeskSpace.n(3))
        }
        .background(DeskColor.background)
    }

    private var errorPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("Rules did not save.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
            Text("Retry the last write.")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
            Button("Retry") {
                Task { await store.flush() }
            }
            .buttonStyle(StampPress())
            .padding(DeskSpace.n(3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var parsedLimit: Double? {
        DeskFigures.parsePositive(limitText)
    }

    private var focusWant: WillCall? {
        if let face = store.desk.faceWant, face.hold == .cooling {
            return face
        }
        return store.desk.coolingWants.first
    }

    private var heroFont: Font {
        if typeSize >= .accessibility1 {
            return DeskFont.headline
        }
        if typeSize >= .xxLarge {
            return DeskFont.title
        }
        return DeskFont.display
    }

    private var isDirty: Bool {
        limitText != originalText
    }

    private func hours(for want: WillCall, limit: Double) -> Double {
        RailHours.hours(
            price: want.price,
            monthlyLimit: limit,
            priority: want.priority,
            necessity: want.necessity,
            discretion: want.discretion
        )
    }

    private func attemptClose() {
        focused = false
        if isDirty && note != "Saved." {
            confirmDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        guard let limit = parsedLimit else {
            note = DeskCopy.fault(.invalidLimit)
            return
        }
        busy = true
        spinTask?.cancel()
        spinTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if !Task.isCancelled {
                await MainActor.run { showSpin = true }
            }
        }
        saveTask = Task {
            do {
                try await store.saveLimit(limit)
                note = "Saved."
                originalText = limitText
            } catch let fault as DeskFault {
                note = DeskCopy.fault(fault)
            } catch {
                note = "Save failed."
            }
            spinTask?.cancel()
            showSpin = false
            busy = false
        }
    }
}
