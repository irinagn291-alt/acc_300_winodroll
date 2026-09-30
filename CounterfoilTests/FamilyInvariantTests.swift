import XCTest
@testable import Counterfoil

/// Family invariant: Base hours from price vs monthly limit. hours = base × priority × (1.5 − nec/100) × (2 − disc/100). Clamp 6…720h. Buy early only by sacrificing another want.
final class FamilyInvariantTests: XCTestCase {
    func test_hoursFromPriceVersusMonthlyLimitThenPriorityNecessityDiscretion() {
        let limit = 720.0
        let price = 72.0
        let base = 720.0 * (price / limit)
        XCTAssertEqual(base, 72, accuracy: 0.000_001)
        let hours = RailHours.hours(
            price: price,
            monthlyLimit: limit,
            priority: 1,
            necessity: 0,
            discretion: 0
        )
        XCTAssertEqual(hours, 72 * 1 * 1.5 * 2, accuracy: 0.000_001)
        XCTAssertEqual(hours, 216, accuracy: 0.000_001)
    }

    func test_hoursClampSixToSevenTwenty() {
        let tiny = RailHours.hours(
            price: 0.01,
            monthlyLimit: 1_000,
            priority: 1,
            necessity: 100,
            discretion: 100
        )
        XCTAssertEqual(tiny, 6, accuracy: 0.000_001)

        let huge = RailHours.hours(
            price: 2_000,
            monthlyLimit: 100,
            priority: 2,
            necessity: 0,
            discretion: 0
        )
        XCTAssertEqual(huge, 720, accuracy: 0.000_001)
    }

    func test_buyEarlyOnlyBySacrificingAnotherWant() throws {
        var desk = Desk.empty
        let now = DeskClock.instant(2026, 9, 19)
        let calendar = DeskClock.calendar
        let face = try desk.fileWant(
            StampDraft(name: "Bag", price: 80, priority: 1, necessity: 40, discretion: 30, retailCode: nil),
            now: now,
            calendar: calendar
        )
        let cover = try desk.fileWant(
            StampDraft(name: "Lamp", price: 200, priority: 1.2, necessity: 20, discretion: 10, retailCode: nil),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(face, now: now, calendar: calendar)
        try desk.stampWant(cover, now: now, calendar: calendar)
        desk.faceID = face
        XCTAssertGreaterThan(desk.remainingHours(at: now), 0)
        XCTAssertThrowsError(
            try desk.releaseFace(fate: .bought, now: now, calendar: calendar)
        ) { error in
            XCTAssertEqual(error as? DeskFault, .railStillRunning)
        }
        XCTAssertEqual(desk.want(face)?.hold, .cooling)
        let outcome = try desk.cutCover(sacrificing: cover, now: now, calendar: calendar)
        XCTAssertEqual(outcome, .covered)
        XCTAssertEqual(desk.want(face)?.hold, .released)
        XCTAssertEqual(desk.want(face)?.fate, .bought)
        XCTAssertEqual(desk.want(cover)?.hold, .released)
        XCTAssertEqual(desk.want(cover)?.fate, .cut)
        XCTAssertEqual(desk.coverMarks.count, 1)
    }
}
