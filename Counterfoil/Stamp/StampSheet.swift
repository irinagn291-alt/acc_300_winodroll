import SwiftUI

/// Role: Stamp. Filing sheet. Name, price, priority, necessity, discretion, optional typed retail code. No camera, no catalog.
struct StampSheet: View {
    var store: DeskStore
    var onStamped: () -> Void
    var onClose: () -> Void

    @State private var name = ""
    @State private var priceText = ""
    @State private var priorityText = "1"
    @State private var necessityText = "50"
    @State private var discretionText = "50"
    @State private var retailCode = ""
    @State private var note: String?
    @State private var busy = false
    @State private var showSpin = false
    @State private var confirmDiscard = false
    @State private var stampTask: Task<Void, Never>?
    @State private var spinTask: Task<Void, Never>?
    @FocusState private var focus: Field?

    private enum Field: Hashable {
        case name, price, priority, necessity, discretion, code
    }

    var body: some View {
        NavigationStack {
            Form {
                if let note {
                    Section {
                        Text(note)
                            .font(DeskFont.body)
                            .foregroundStyle(DeskColor.ink)
                    }
                    .deskRowSurface()
                }
                if store.desk.wants.isEmpty {
                    Section {
                        Text("File the first want.")
                            .font(DeskFont.body)
                            .foregroundStyle(DeskColor.muted)
                    }
                    .deskRowSurface()
                }
                Section("Want") {
                    TextField("Name", text: $name)
                        .focused($focus, equals: .name)
                        .font(DeskFont.body)
                        .textInputAutocapitalization(.words)
                        .deskRowSurface()
                    TextField("Price", text: $priceText)
                        .focused($focus, equals: .price)
                        .keyboardType(.decimalPad)
                        .font(DeskFont.body)
                        .monospacedDigit()
                        .deskRowSurface()
                    TextField("Priority", text: $priorityText)
                        .focused($focus, equals: .priority)
                        .keyboardType(.decimalPad)
                        .font(DeskFont.body)
                        .monospacedDigit()
                        .deskRowSurface()
                    TextField("Necessity, 0 to 100", text: $necessityText)
                        .focused($focus, equals: .necessity)
                        .keyboardType(.decimalPad)
                        .font(DeskFont.body)
                        .monospacedDigit()
                        .deskRowSurface()
                    TextField("Discretion, 0 to 100", text: $discretionText)
                        .focused($focus, equals: .discretion)
                        .keyboardType(.decimalPad)
                        .font(DeskFont.body)
                        .monospacedDigit()
                        .deskRowSurface()
                    TextField("Retail code, optional", text: $retailCode)
                        .focused($focus, equals: .code)
                        .keyboardType(.asciiCapable)
                        .font(DeskFont.body)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .deskRowSurface()
                }
                if let hours = previewHours {
                    Section("Hold") {
                        Text(DeskFigures.hours(hours) + " hours")
                            .font(DeskFont.headline)
                            .foregroundStyle(DeskColor.ink)
                            .monospacedDigit()
                            .deskRowSurface()
                        Text("Same retail code keeps the longer span.")
                            .font(DeskFont.caption)
                            .foregroundStyle(DeskColor.muted)
                            .deskRowSurface()
                    }
                }
                Section {
                    Button("Stamp") { stamp() }
                        .buttonStyle(StampPress(isLoading: showSpin))
                        .disabled(busy || draft == nil)
                        .listRowInsets(EdgeInsets(
                            top: DeskSpace.n(1),
                            leading: DeskSpace.n(2),
                            bottom: DeskSpace.n(1),
                            trailing: DeskSpace.n(2)
                        ))
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .background(DeskColor.background)
            .navigationTitle("Stamp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DeskClose(action: attemptClose)
                        .disabled(busy)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                        .frame(minHeight: DeskSpace.n(6))
                }
            }
            .onDisappear {
                stampTask?.cancel()
                spinTask?.cancel()
            }
            .confirmationDialog("Discard this want?", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("Discard", role: .destructive, action: onClose)
                Button("Keep", role: .cancel) {}
            } message: {
                Text("The name and figures are not stamped.")
            }
        }
    }

    private var isDirty: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = retailCode.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
            || !priceText.isEmpty
            || priorityText != "1"
            || necessityText != "50"
            || discretionText != "50"
            || !trimmedCode.isEmpty
    }

    private var draft: StampDraft? {
        guard let price = DeskFigures.parsePositive(priceText),
              let priority = DeskFigures.parsePositive(priorityText),
              let necessity = DeskFigures.parseClosed(necessityText, min: 0, max: 100),
              let discretion = DeskFigures.parseClosed(discretionText, min: 0, max: 100)
        else { return nil }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }
        let code = retailCode.trimmingCharacters(in: .whitespacesAndNewlines)
        return StampDraft(
            name: trimmedName,
            price: price,
            priority: priority,
            necessity: necessity,
            discretion: discretion,
            retailCode: code.isEmpty ? nil : code
        )
    }

    private var previewHours: Double? {
        guard let draft else { return nil }
        return RailHours.hours(
            price: draft.price,
            monthlyLimit: store.desk.rules.monthlyImpulseLimit,
            priority: draft.priority,
            necessity: draft.necessity,
            discretion: draft.discretion
        )
    }

    private func attemptClose() {
        focus = nil
        if isDirty {
            confirmDiscard = true
        } else {
            onClose()
        }
    }

    private func stamp() {
        guard let draft else {
            note = DeskCopy.fault(.emptyName)
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
        stampTask = Task {
            do {
                let id = try await store.fileWant(draft)
                try await store.stampWant(id)
                spinTask?.cancel()
                showSpin = false
                busy = false
                onStamped()
            } catch let fault as DeskFault {
                note = DeskCopy.fault(fault)
                spinTask?.cancel()
                showSpin = false
                busy = false
            } catch {
                note = "Stamp failed."
                spinTask?.cancel()
                showSpin = false
                busy = false
            }
        }
    }
}
