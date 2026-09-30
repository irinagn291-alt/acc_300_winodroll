import XCTest
@testable import Counterfoil

/// Primary verb Stamp: empty, populated, and invalid input. No View.
final class StampVerbTests: XCTestCase {
    private var now: Date { DeskClock.instant(2026, 9, 19) }
    private var calendar: Calendar { DeskClock.calendar }

    func test_emptyDeskCannotStampUnknownWant() {
        var desk = Desk.empty
        XCTAssertFalse(desk.canStamp)
        XCTAssertThrowsError(try desk.stampWant(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? DeskFault, .wantUnknown)
        }
        XCTAssertEqual(desk.fold, .blank)
    }

    func test_populatedStampWritesTicketAndEnablesRail() throws {
        var desk = Desk.empty
        let id = try desk.fileWant(
            StampDraft(name: "Lamp", price: 90, priority: 1, necessity: 40, discretion: 40, retailCode: "12345678"),
            now: now,
            calendar: calendar
        )
        XCTAssertTrue(desk.canStamp)
        try desk.stampWant(id, now: now, calendar: calendar)
        XCTAssertEqual(desk.fold, .cooling)
        XCTAssertGreaterThan(desk.remainingHours(at: now), 0)
        XCTAssertEqual(desk.want(id)?.ticket?.computedHours, RailHours.hours(
            price: 90,
            monthlyLimit: desk.rules.monthlyImpulseLimit,
            priority: 1,
            necessity: 40,
            discretion: 40
        ))
    }

    func test_invalidFileWantIsRefused() {
        var desk = Desk.empty
        XCTAssertThrowsError(
            try desk.fileWant(
                StampDraft(name: "   ", price: 10, priority: 1, necessity: 10, discretion: 10, retailCode: nil),
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? DeskFault, .emptyName)
        }
        XCTAssertThrowsError(
            try desk.fileWant(
                StampDraft(name: "Bag", price: -4, priority: 1, necessity: 10, discretion: 10, retailCode: nil),
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? DeskFault, .invalidPrice)
        }
        XCTAssertThrowsError(
            try desk.fileWant(
                StampDraft(name: "Bag", price: 10, priority: 0, necessity: 10, discretion: 10, retailCode: nil),
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? DeskFault, .invalidPriority)
        }
        XCTAssertThrowsError(
            try desk.fileWant(
                StampDraft(name: "Bag", price: 10, priority: 1, necessity: 140, discretion: 10, retailCode: nil),
                now: now,
                calendar: calendar
            )
        ) { error in
            XCTAssertEqual(error as? DeskFault, .invalidNecessity)
        }
        XCTAssertTrue(desk.wants.isEmpty)
    }

    func test_remainingHoursFloorAtZero() throws {
        var desk = Desk.empty
        let id = try desk.fileWant(
            StampDraft(name: "Bag", price: 40, priority: 1, necessity: 50, discretion: 50, retailCode: nil),
            now: now,
            calendar: calendar
        )
        try desk.stampWant(id, now: now, calendar: calendar)
        let ticket = try XCTUnwrap(desk.want(id)?.ticket)
        let later = ticket.stampedAt.addingTimeInterval(ticket.computedHours * 3600 + 80)
        XCTAssertEqual(desk.want(id)?.remainingHours(at: later), 0)
        XCTAssertTrue(desk.canRelease(at: later))
    }
}
