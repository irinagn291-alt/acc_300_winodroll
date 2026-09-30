import XCTest
@testable import Counterfoil

/// Architecture: Hold-ticket ADT fold Blank | Cooling | Released. Stamp samples not-Released. Cut on Blank is refused. Short cover keeps. CoverMark folds. Longer-span rehold. Empty desk writes Blank. No View.
final class DeskFoldTests: XCTestCase {
    private var now: Date { DeskClock.instant(2026, 9, 19) }
    private var calendar: Calendar { DeskClock.calendar }

    func test_emptyDeskWritesBlank() {
        let desk = Desk.empty
        XCTAssertEqual(desk.fold, .blank)
        XCTAssertTrue(desk.wants.isEmpty)
        XCTAssertNil(desk.faceWant)
    }

    func test_stampSamplesNotReleased_andFoldsBlankToCooling() throws {
        var desk = Desk.empty
        let blank = try desk.fileWant(
            StampDraft(name: "Bag", price: 40, priority: 1, necessity: 50, discretion: 50, retailCode: "111"),
            now: now,
            calendar: calendar
        )
        let spent = try desk.fileWant(
            StampDraft(name: "Old", price: 12, priority: 1, necessity: 50, discretion: 50, retailCode: nil),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(spent, now: now, calendar: calendar)
        try desk.releaseFace(
            fate: .dropped,
            now: now.addingTimeInterval(720 * 3600),
            calendar: calendar
        )
        XCTAssertEqual(desk.want(spent)?.hold, .released)
        XCTAssertThrowsError(try desk.stampWant(spent, now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? DeskFault, .stampReleased)
        }
        try desk.stampWant(blank, now: now, calendar: calendar)
        XCTAssertEqual(desk.fold, .cooling)
        XCTAssertEqual(desk.want(blank)?.hold, .cooling)
        XCTAssertNotNil(desk.want(blank)?.ticket)
        XCTAssertEqual(desk.faceID, blank)
    }

    func test_cutOnBlankIsRefused() {
        var desk = Desk.empty
        XCTAssertEqual(desk.fold, .blank)
        XCTAssertThrowsError(
            try desk.cutCover(sacrificing: UUID(), now: now, calendar: calendar)
        ) { error in
            XCTAssertEqual(error as? DeskFault, .cutOnBlank)
        }
    }

    func test_shortCoverWritesShortMarkAndKeepsTicket() throws {
        var desk = try twoCooling(facePrice: 200, coverPrice: 12)
        let faceID = try XCTUnwrap(desk.faceID)
        let coverID = try XCTUnwrap(desk.coolingWants.first { $0.id != faceID }?.id)
        let before = desk.want(faceID)?.ticket
        let outcome = try desk.cutCover(sacrificing: coverID, now: now, calendar: calendar)
        XCTAssertEqual(outcome, .short)
        XCTAssertEqual(desk.want(faceID)?.hold, .cooling)
        XCTAssertEqual(desk.want(faceID)?.ticket, before)
        XCTAssertEqual(desk.shortMarks.count, 1)
        XCTAssertTrue(desk.coverMarks.isEmpty)
        XCTAssertEqual(desk.fold, .cooling)
    }

    func test_coverMarkFoldsCoolingToReleased() throws {
        var desk = try twoCooling(facePrice: 20, coverPrice: 200)
        let faceID = try XCTUnwrap(desk.faceID)
        let coverID = try XCTUnwrap(desk.coolingWants.first { $0.id != faceID }?.id)
        let outcome = try desk.cutCover(sacrificing: coverID, now: now, calendar: calendar)
        XCTAssertEqual(outcome, .covered)
        XCTAssertEqual(desk.want(faceID)?.hold, .released)
        XCTAssertEqual(desk.want(faceID)?.fate, .bought)
        XCTAssertEqual(desk.want(coverID)?.hold, .released)
        XCTAssertEqual(desk.want(coverID)?.fate, .cut)
        XCTAssertEqual(desk.coverMarks.count, 1)
        XCTAssertEqual(desk.coverMarks[0].releasedWantID, faceID)
        XCTAssertEqual(desk.coverMarks[0].sacrificedWantID, coverID)
        XCTAssertNotEqual(desk.fold, .cooling)
    }

    func test_longerSpanReholdKeepsStampedAtAndTakesMaxHours() throws {
        var desk = Desk.empty
        let id = try desk.fileWant(
            StampDraft(name: "Bag", price: 40, priority: 1, necessity: 80, discretion: 80, retailCode: "999111"),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(id, now: now, calendar: calendar)
        let first = try XCTUnwrap(desk.want(id)?.ticket)
        let later = now.addingTimeInterval(3_600)
        if let index = desk.wants.firstIndex(where: { $0.id == id }) {
            desk.wants[index].price = 300
            desk.wants[index].necessity = 0
            desk.wants[index].discretion = 0
        }
        try desk.stampWant(id, now: later, calendar: calendar)
        let second = try XCTUnwrap(desk.want(id)?.ticket)
        XCTAssertEqual(second.stampedAt, first.stampedAt)
        XCTAssertGreaterThan(second.computedHours, first.computedHours)
        XCTAssertEqual(second.computedHours, max(first.computedHours, second.computedHours))
        XCTAssertEqual(desk.fold, .cooling)
    }

    func test_sameRetailCodeWhileCoolingReholdsExistingTicket() throws {
        var desk = Desk.empty
        let first = try desk.fileWant(
            StampDraft(name: "Bag", price: 30, priority: 1, necessity: 50, discretion: 50, retailCode: "555000"),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(first, now: now, calendar: calendar)
        let original = try XCTUnwrap(desk.want(first)?.ticket)
        let twin = try desk.fileWant(
            StampDraft(name: "Bag again", price: 180, priority: 1.4, necessity: 10, discretion: 10, retailCode: "555000"),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(twin, now: now.addingTimeInterval(120), calendar: calendar)
        XCTAssertEqual(desk.want(first)?.hold, .cooling)
        XCTAssertEqual(desk.want(twin)?.hold, .blank)
        let kept = try XCTUnwrap(desk.want(first)?.ticket)
        XCTAssertEqual(kept.stampedAt, original.stampedAt)
        XCTAssertGreaterThan(kept.computedHours, original.computedHours)
        XCTAssertEqual(desk.coolingWants.count, 1)
    }

    private func twoCooling(facePrice: Double, coverPrice: Double) throws -> Desk {
        var desk = Desk.empty
        let face = try desk.fileWant(
            StampDraft(name: "Face", price: facePrice, priority: 1, necessity: 20, discretion: 20, retailCode: nil),
            now: now,
            calendar: calendar
        )
        let cover = try desk.fileWant(
            StampDraft(name: "Cover", price: coverPrice, priority: 1, necessity: 20, discretion: 20, retailCode: nil),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(face, now: now, calendar: calendar)
        try desk.stampWant(cover, now: now, calendar: calendar)
        desk.faceID = face
        return desk
    }
}
