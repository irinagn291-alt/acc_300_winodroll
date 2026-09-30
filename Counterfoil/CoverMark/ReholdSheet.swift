import SwiftUI

/// Role: CoverMark. Twist screen for longer-span rehold. Same retail code keeps the longer computed hours.
struct ReholdSheet: View {
    var store: DeskStore
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if store.lastWriteError != nil && store.desk.faceWant == nil {
                    errorPage
                } else if store.desk.wants.isEmpty {
                    emptyPage
                } else {
                    populated
                }
            }
            .background(DeskColor.background)
            .navigationTitle("Longer span")
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
            Section {
                CutoutArt(resource: "ctf_TwistHero", maxHeight: DeskSpace.n(18))
                    .listRowInsets(EdgeInsets(
                        top: DeskSpace.n(2),
                        leading: DeskSpace.n(2),
                        bottom: DeskSpace.n(2),
                        trailing: DeskSpace.n(2)
                    ))
                    .deskRowSurface()
            }
            Section {
                Text("Same retail code keeps the longer span.")
                    .font(DeskFont.headline)
                    .foregroundStyle(DeskColor.ink)
                    .deskRowSurface()
                Text("The rail does not restart. Hours come from price versus the monthly limit, then priority, necessity, and discretion.")
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.muted)
                    .deskRowSurface()
            }
            if let face = store.desk.faceWant, let ticket = face.ticket {
                Section("This ticket") {
                    Text(face.name)
                        .font(DeskFont.body)
                        .foregroundStyle(DeskColor.ink)
                        .lineLimit(1)
                        .deskRowSurface()
                    HStack {
                        Text("Stamped hours")
                            .foregroundStyle(DeskColor.muted)
                        Spacer()
                        Text(DeskFigures.hours(ticket.computedHours))
                            .monospacedDigit()
                            .foregroundStyle(DeskColor.ink)
                    }
                    .font(DeskFont.body)
                    .deskRowSurface()
                    if let code = face.normalizedCode {
                        HStack {
                            Text("Retail code")
                                .foregroundStyle(DeskColor.muted)
                            Spacer()
                            Text(code)
                                .foregroundStyle(DeskColor.ink)
                                .lineLimit(1)
                        }
                        .font(DeskFont.caption)
                        .deskRowSurface()
                    }
                }
            }
            Section {
                Text("Cut early only by dropping another cooling ticket whose remaining hours cover this rail.")
                    .font(DeskFont.caption)
                    .foregroundStyle(DeskColor.muted)
                    .deskRowSurface()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var emptyPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_TwistHero")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("Stamp a want first.")
                .font(DeskFont.title)
                .foregroundStyle(DeskColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
            Text("Rehold needs a cooling ticket with a retail code.")
                .font(DeskFont.body)
                .foregroundStyle(DeskColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DeskSpace.n(3))
                .padding(.top, DeskSpace.n(1))
            Button("Close", action: onClose)
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
            Text("Rehold did not load.")
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
}
