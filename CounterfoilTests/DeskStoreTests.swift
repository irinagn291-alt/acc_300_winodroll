import XCTest
@testable import Counterfoil

final class DeskStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var calendar: Calendar { DeskClock.calendar }
    private var now: Date { DeskClock.instant(2026, 9, 19) }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "ctf.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
        if let suiteName {
            defaults?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        defaults = nil
        suiteName = nil
    }

    @MainActor
    func test_roundTrip_reloadPreservesHoldAndMarks() async throws {
        let store = makeStore()
        await store.load()
        let face = try await store.fileWant(
            StampDraft(name: "Bag", price: 80, priority: 1, necessity: 40, discretion: 30, retailCode: "111"),
            now: now,
            calendar: calendar
        )
        let cover = try await store.fileWant(
            StampDraft(name: "Lamp", price: 220, priority: 1.2, necessity: 15, discretion: 10, retailCode: "222"),
            now: now,
            calendar: calendar
        )
        try await store.stampWant(cover, now: now, calendar: calendar)
        try await store.stampWant(face, now: now, calendar: calendar)
        let outcome = try await store.cutCover(sacrificing: cover, now: now, calendar: calendar)
        XCTAssertEqual(outcome, .covered)
        await store.flush()

        let relaunched = makeStore()
        await relaunched.load()
        XCTAssertNil(relaunched.warning)
        XCTAssertEqual(relaunched.desk.wants.count, 2)
        XCTAssertEqual(relaunched.desk.coverMarks.count, 1)
        XCTAssertEqual(relaunched.desk.want(face)?.hold, .released)
        XCTAssertEqual(relaunched.desk.want(cover)?.fate, .cut)
        XCTAssertNotNil(defaults.data(forKey: DeskKey.snapshot))
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: directory.appendingPathComponent("desk.json").path)
        )
        let json = String(decoding: try XCTUnwrap(defaults.data(forKey: DeskKey.snapshot)), as: UTF8.self)
        XCTAssertTrue(json.contains("cooling") || json.contains("released") || json.contains("blank"))
        XCTAssertFalse(json.contains("isCooling"))
    }

    @MainActor
    func test_corruptSnapshotFallsBackToBackup() async throws {
        let store = makeStore()
        await store.load()
        let id = try await store.fileWant(
            StampDraft(name: "Bag", price: 40, priority: 1, necessity: 50, discretion: 50, retailCode: nil),
            now: now,
            calendar: calendar
        )
        try await store.stampWant(id, now: now, calendar: calendar)
        await store.flush()
        if let good = defaults.data(forKey: DeskKey.snapshot) {
            defaults.set(good, forKey: DeskKey.backup)
        }
        let file = directory.appendingPathComponent("desk.json")
        let backup = directory.appendingPathComponent("desk.json.backup")
        if FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.removeItem(at: backup)
            try FileManager.default.copyItem(at: file, to: backup)
        }
        defaults.set(Data("not-json".utf8), forKey: DeskKey.snapshot)
        try Data("not-json".utf8).write(to: file, options: .atomic)

        let relaunched = makeStore()
        await relaunched.load()
        XCTAssertEqual(relaunched.warning, .recoveredFromBackup)
        XCTAssertEqual(relaunched.desk.want(id)?.hold, .cooling)
    }

    @MainActor
    func test_resetAllDataClearsSuite() async throws {
        let store = makeStore()
        await store.load()
        _ = try await store.fileWant(
            StampDraft(name: "Bag", price: 40, priority: 1, necessity: 50, discretion: 50, retailCode: nil),
            now: now,
            calendar: calendar
        )
        await store.flush()
        await store.resetAllData()
        XCTAssertEqual(store.desk, .empty)
        XCTAssertNil(defaults.data(forKey: DeskKey.snapshot))
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.appendingPathComponent("desk.json").path))
    }

    @MainActor
    func test_seedHasLiveCoolingAndCutCover() {
        let seeded = DeskSeed.desk(now: now, calendar: calendar)
        XCTAssertTrue(seeded.onboardingComplete)
        XCTAssertEqual(seeded.fold, .cooling)
        XCTAssertGreaterThan(seeded.remainingHours(at: now), 0)
        XCTAssertTrue(seeded.canStamp)
        XCTAssertTrue(seeded.canCut(at: now))
        XCTAssertFalse(seeded.releasedWants.isEmpty)
        XCTAssertFalse(seeded.cutWants.isEmpty)
        XCTAssertGreaterThanOrEqual(seeded.coolingWants.count, 2)
        XCTAssertNotEqual(seeded.fold, .blank)
    }

    @MainActor
    private func makeStore() -> DeskStore {
        DeskStore(directory: directory, suiteName: suiteName, writeDelayNanoseconds: 0)
    }
}
