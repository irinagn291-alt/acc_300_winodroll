import SwiftUI

/// Role: Desk. Settings: contact URL, re-run onboarding, resetAllData. Empty, populated, error.
struct DeskSettings: View {
    var store: DeskStore
    var onClose: () -> Void

    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Group {
                if store.lastWriteError != nil && store.desk.wants.isEmpty && !store.desk.onboardingComplete {
                    errorPage
                } else {
                    form
                }
            }
            .background(DeskColor.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DeskClose(action: onClose)
                }
            }
            .confirmationDialog("Reset the desk?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset the desk", role: .destructive) {
                    Task {
                        await store.resetAllData()
                        onClose()
                    }
                }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("All tickets, marks, and the monthly limit go.")
            }
        }
    }

    private var form: some View {
        Form {
            if store.desk.wants.isEmpty {
                Section {
                    Text("Desk is clear.")
                        .font(DeskFont.body)
                        .foregroundStyle(DeskColor.muted)
                }
                .deskRowSurface()
            }
            Section("Contact") {
                if let url = DeskNet.contactURL {
                    Link(destination: url) {
                        HStack(spacing: DeskSpace.n(1)) {
                            Image(systemName: "envelope")
                                .accessibilityHidden(true)
                            Text("https://counterfoil-desk.pro/contact-us")
                                .lineLimit(1)
                            Spacer(minLength: DeskSpace.n(1))
                        }
                        .font(DeskFont.body)
                        .foregroundStyle(DeskColor.accent)
                        .frame(minHeight: DeskSpace.n(6), alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Contact")
                    .deskRowSurface()
                } else {
                    Text("Contact is unavailable.")
                        .font(DeskFont.body)
                        .foregroundStyle(DeskColor.muted)
                        .deskRowSurface()
                }
            }
            Section("Desk") {
                Button {
                    Task {
                        await store.setOnboardingComplete(false)
                        await store.flush()
                        onClose()
                    }
                } label: {
                    HStack(spacing: DeskSpace.n(1)) {
                        Image(systemName: "arrow.counterclockwise")
                            .accessibilityHidden(true)
                        Text("Show the intro")
                        Spacer(minLength: DeskSpace.n(1))
                    }
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.ink)
                    .frame(minHeight: DeskSpace.n(6), alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ChromePress())
                .deskRowSurface()
                Button {
                    confirmReset = true
                } label: {
                    HStack(spacing: DeskSpace.n(1)) {
                        Image(systemName: "trash")
                            .accessibilityHidden(true)
                        Text("Reset the desk")
                        Spacer(minLength: DeskSpace.n(1))
                    }
                    .font(DeskFont.body)
                    .foregroundStyle(DeskColor.muted)
                    .frame(minHeight: DeskSpace.n(6), alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ChromePress())
                .deskRowSurface()
                .accessibilityLabel("Reset the desk")
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var errorPage: some View {
        VStack(spacing: 0) {
            CutoutArt(resource: "ctf_EmptyList")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, DeskSpace.n(4))
            Text("Settings did not save.")
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
