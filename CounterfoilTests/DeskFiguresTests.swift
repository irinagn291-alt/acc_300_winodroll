import XCTest
@testable import Counterfoil

/// Display numbers go through NumberFormatter. No View.
final class DeskFiguresTests: XCTestCase {
    func test_parseRejectsEmptyNegativeAndNonNumeric() {
        XCTAssertNil(DeskFigures.parseDecimal(""))
        XCTAssertNil(DeskFigures.parseDecimal("  "))
        XCTAssertNil(DeskFigures.parseDecimal("bag"))
        XCTAssertNil(DeskFigures.parsePositive("-4"))
        XCTAssertNil(DeskFigures.parsePositive("0"))
        XCTAssertEqual(DeskFigures.parsePositive("12.5"), 12.5)
        XCTAssertEqual(DeskFigures.parseClosed("0", min: 0, max: 100), 0)
        XCTAssertEqual(DeskFigures.parseClosed("100", min: 0, max: 100), 100)
        XCTAssertNil(DeskFigures.parseClosed("140", min: 0, max: 100))
    }

    func test_hoursAndMoneyUseFormatters() {
        let hours = DeskFigures.hours(148.25)
        XCTAssertFalse(hours.isEmpty)
        XCTAssertNotEqual(hours, "148.25")
        let money = DeskFigures.money(80)
        XCTAssertFalse(money.isEmpty)
        XCTAssertFalse(money.contains("{"))
        XCTAssertEqual(DeskFigures.count(2), NumberFormatter.localizedString(from: 2, number: .decimal))
    }

    func test_claimSheetMapsLaunchPanes() {
        XCTAssertNil(ClaimSheet.from(pane: .desk))
        XCTAssertEqual(ClaimSheet.from(pane: .review), .review)
        XCTAssertEqual(ClaimSheet.from(pane: .rules), .rules)
        XCTAssertEqual(ClaimSheet.from(pane: .settings), .settings)
        XCTAssertNil(ClaimSheet.from(hook: .today))
        XCTAssertEqual(ClaimSheet.from(hook: .rehold), .rehold)
        XCTAssertNotEqual(ClaimSheet.review, ClaimSheet.rules)
        XCTAssertNotEqual(ClaimSheet.rules, ClaimSheet.settings)
        XCTAssertEqual(DeskCopy.fault(.cutOnBlank), "Cut needs a cooling ticket.")
        XCTAssertEqual(DeskCopy.hold(.cooling, fate: nil), "Cooling")
        XCTAssertEqual(DeskCopy.hold(.released, fate: .cut), "Released, cut")
        XCTAssertEqual(
            DeskCopy.limitShift(draft: 400, saved: 400),
            "This limit matches the hours already on the rail."
        )
        XCTAssertEqual(
            DeskCopy.limitShift(draft: 800, saved: 400),
            "Raising the limit shortens hours on the live tickets."
        )
        XCTAssertEqual(
            DeskCopy.limitShift(draft: 200, saved: 400),
            "Lowering the limit lengthens hours on the live tickets."
        )
        let atFourHundred = RailHours.hours(
            price: 80,
            monthlyLimit: 400,
            priority: 1,
            necessity: 40,
            discretion: 30
        )
        let atEightHundred = RailHours.hours(
            price: 80,
            monthlyLimit: 800,
            priority: 1,
            necessity: 40,
            discretion: 30
        )
        XCTAssertLessThan(atEightHundred, atFourHundred)
    }
}
