import Foundation
import Observation

/// Role: Desk. Observable fold owner. Memory is the source of truth. UserDefaults is the projection. Views call stampWant and cutCover and never store a parallel cooling bool.
@MainActor
@Observable
final class DeskStore {
    private(set) var desk: Desk
    private(set) var warning: DeskWarning?
    private(set) var lastWriteError: String?

    private let vault: DeskVault
    private let writeDelayNanoseconds: UInt64
    private var persistTask: Task<Void, Never>?

    init(
        directory: URL,
        suiteName: String? = nil,
        writeDelayNanoseconds: UInt64 = 280_000_000
    ) {
        self.vault = DeskVault(directory: directory, suiteName: suiteName)
        self.writeDelayNanoseconds = writeDelayNanoseconds
        self.desk = .empty
        self.warning = nil
        self.lastWriteError = nil
    }

    convenience init() {
        let directory: URL
        do {
            directory = try DeskVault.supportDirectory()
        } catch {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent(
                "Winodroll",
                isDirectory: true
            )
        }
        self.init(directory: directory)
    }

    func load() async {
        let loaded = await vault.load()
        desk = loaded.desk
        warning = loaded.warning
        lastWriteError = nil
    }

    @discardableResult
    func fileWant(_ draft: StampDraft, now: Date = Date(), calendar: Calendar = .current) async throws -> UUID {
        var next = desk
        let id = try next.fileWant(draft, now: now, calendar: calendar)
        desk = next
        schedulePersist()
        return id
    }

    func stampWant(_ id: UUID, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = desk
        try next.stampWant(id, now: now, calendar: calendar)
        desk = next
        await persistNow()
    }

    @discardableResult
    func cutCover(sacrificing coverID: UUID, now: Date = Date(), calendar: Calendar = .current) async throws -> CutOutcome {
        var next = desk
        let outcome = try next.cutCover(sacrificing: coverID, now: now, calendar: calendar)
        desk = next
        await persistNow()
        return outcome
    }

    func releaseFace(fate: ClaimFate, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = desk
        try next.releaseFace(fate: fate, now: now, calendar: calendar)
        desk = next
        await persistNow()
    }

    func saveLimit(_ monthlyImpulseLimit: Double) async throws {
        var next = desk
        try next.saveLimit(monthlyImpulseLimit)
        desk = next
        await persistNow()
    }

    func setOnboardingComplete(_ flag: Bool) async {
        var next = desk
        next.setOnboardingComplete(flag)
        desk = next
        schedulePersist()
    }

    func flush() async {
        persistTask?.cancel()
        persistTask = nil
        await persistNow()
    }

    func resetAllData() async {
        persistTask?.cancel()
        persistTask = nil
        desk = .empty
        warning = nil
        lastWriteError = nil
        do {
            try await vault.wipe()
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    func seedDemoIfNeeded(now: Date = Date(), calendar: Calendar = .current) async {
        #if targetEnvironment(simulator)
        if await vault.demoPlanted() { return }
        desk = DeskSeed.desk(now: now, calendar: calendar)
        await vault.markDemoPlanted()
        await persistNow()
        #else
        _ = now
        _ = calendar
        #endif
    }

    private func persistNow() async {
        persistTask?.cancel()
        persistTask = nil
        do {
            try await vault.save(desk)
            lastWriteError = nil
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    private func schedulePersist() {
        persistTask?.cancel()
        let delay = writeDelayNanoseconds
        persistTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.persistNow()
        }
    }
}
