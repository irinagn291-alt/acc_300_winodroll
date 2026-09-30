import SwiftUI

/// Role: Ticket. Review of released, cut, and still-cooling tickets. Stock List. Empty, populated, error.
struct ClaimReview: View {
    var store: DeskStore
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if store.lastWriteError != nil && store.desk.wants.isEmpty {
                    errorPage
                } else if store.desk.releasedWants.isEmpty
                    && store.desk.cutWants.isEmpty
                    && store.desk.coolingWants.isEmpty {
                    emptyPage
                } else {
                    populated
                }
            }
            .background(DeskColor.background)
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DeskClose(action: onClose)
                }
            }
        }
    }

    private var populated: some View {
        List {
            if !store.desk.releasedWants.isEmpty {
                Section("Released") {
                    ForEach(store.desk.releasedWants) { want in
                        reviewRow(want)
                    }
                }
            }
            if !store.desk.cutWants.isEmpty {
                Section("Cut") {
                    ForEach(store.desk.cutWants) { want in
                        reviewRow(want)
                    }
                }
            }
            if !store.desk.coolingWants.isEmpty {
                Section("Cooling") {
                    ForEach(store.desk.coolingWants) { want in
                        reviewRow(want)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, DeskSpace.n(2))
    }

    private func reviewRow(_ want: WillCall) -> some View {
        VStack(alignment: .leading, spacing: DeskSpace.n(1)) {
            HStack(alignment: .firstTextBaseline, spacing: DeskSpace.n(1)) {
                Text(want.name)
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .lineLimit(1)
                Spacer(minLength: DeskSpace.n(1))
                Text(DeskFigures.money(want.price))
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            HStack(spacing: DeskSpace.n(1)) {
                Image(systemName: DeskCopy.holdSymbol(want.hold, fate: want.fate))
                    .accessibilityHidden(true)
                Text(DeskCopy.hold(want.hold, fate: want.fate))
                if want.hold == .cooling, let ticket = want.ticket {
                    Text(DeskFigures.hours(ticket.computedHours) + " h")
                        .monospacedDigit()
                }
            }
            .font(DeskFont.caption)
            .foregroundStyle(DeskColor.muted)
        }
        .padding(.vertical, DeskSpace.n(1))
        .deskRowSurface()
        .accessibilityElement(children: .combine)
    }

    private var emptyPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("No tickets yet.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
            Text("Released, cut, and cooling land here.")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
            Button("Stamp a want", action: onClose)
                .buttonStyle(StampPress())
                .padding(DeskSpace.n(3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("Review did not load.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
            Text("The desk did not save. Retry, or close.")
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
}
