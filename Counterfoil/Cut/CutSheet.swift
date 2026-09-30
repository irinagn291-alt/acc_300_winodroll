import SwiftUI

/// Role: Cut. Pick another cooling ticket. Cover writes a CoverMark. Short writes a ShortMark and keeps this ticket.
struct CutSheet: View {
    var store: DeskStore
    var onCovered: () -> Void
    var onShort: () -> Void
    var onClose: () -> Void

    @State private var busy = false
    @State private var showSpinFor: UUID?
    @State private var note: String?
    @State private var pickTask: Task<Void, Never>?
    @State private var spinTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if store.desk.fold != .cooling {
                    errorPage
                } else if others.isEmpty {
                    emptyPage
                } else {
                    populated
                }
            }
            .background(DeskColor.background)
            .navigationTitle("Cut")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DeskClose(action: onClose)
                        .disabled(busy)
                }
            }
            .onDisappear {
                pickTask?.cancel()
                spinTask?.cancel()
            }
        }
    }

    private var now: Date { Date() }

    private var others: [WillCall] {
        store.desk.coolingWants.filter { $0.id != store.desk.faceID }
    }

    private var covering: Set<UUID> {
        Set(store.desk.coveringIDs(at: now))
    }

    private var populated: some View {
        List {
            if let note {
                Section {
                    Text(note)
                        .font(DeskFont.body)
                        .foregroundStyle(DeskColor.ink)
                }
                .deskRowSurface()
            }
            Section("Cooling tickets") {
                ForEach(others) { want in
                    Button {
                        pick(want.id)
                    } label: {
                        row(want)
                    }
                    .buttonStyle(ChromePress())
                    .disabled(busy)
                    .deskRowSurface()
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func row(_ want: WillCall) -> some View {
        let offered = want.remainingHours(at: now)
        let covers = covering.contains(want.id)
        return HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(1)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(want.name)
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .lineLimit(1)
                HStack(spacing: DeskSpace.n(1)) {
                    Image(systemName: covers ? "checkmark.circle" : "clock")
                        .accessibilityHidden(true)
                    Text(covers ? "Cover" : "Short")
                    Text(DeskFigures.hours(offered) + " h left")
                        .monospacedDigit()
                }
                .font(DeskFont.caption)
                .foregroundStyle(DeskColor.muted)
            }
            Spacer(minLength: DeskSpace.n(1))
            if showSpinFor == want.id {
                ProgressView()
                    .tint(DeskColor.ink)
            }
        }
        .padding(.vertical, DeskSpace.n(1))
        .frame(minHeight: DeskSpace.n(6), alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityLabel("\(want.name), \(covers ? "Cover" : "Short"), \(DeskFigures.hours(offered)) hours left")
    }

    private var emptyPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("No other cooling ticket.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
            Text("Stamp another want to cut.")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
            Button("Close", action: onClose)
                .buttonStyle(StampPress(kind: .cut))
                .padding(DeskSpace.n(3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("Cut is refused.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
            Text(DeskCopy.fault(.cutOnBlank))
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
            Button("Close", action: onClose)
                .buttonStyle(StampPress(kind: .cut))
                .padding(DeskSpace.n(3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func pick(_ id: UUID) {
        busy = true
        spinTask?.cancel()
        spinTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if !Task.isCancelled {
                await MainActor.run { showSpinFor = id }
            }
        }
        pickTask?.cancel()
        pickTask = Task {
            do {
                let outcome = try await store.cutCover(sacrificing: id)
                spinTask?.cancel()
                busy = false
                showSpinFor = nil
                switch outcome {
                case .covered:
                    onCovered()
                case .short:
                    note = "Cover is short. Ticket stays."
                    onShort()
                }
            } catch let fault as DeskFault {
                note = DeskCopy.fault(fault)
                spinTask?.cancel()
                busy = false
                showSpinFor = nil
            } catch {
                note = "Cut failed."
                spinTask?.cancel()
                busy = false
                showSpinFor = nil
            }
        }
    }
}
