import XCTest
@testable import Counterfoil

final class DeskLaunchTests: XCTestCase {
    func test_readsOnceAfterOnboarding() {
        var consumed = false
        XCTAssertNil(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: false,
                consumed: &consumed
            )
        )
        XCTAssertFalse(consumed)

        let first = DeskLaunch.consume(
            arguments: ["app", "-ReviewScreen", "log"],
            onboardingComplete: true,
            consumed: &consumed
        )
        XCTAssertEqual(first, .log)
        XCTAssertEqual(first?.pane, .review)
        XCTAssertTrue(consumed)
        XCTAssertNil(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
    }

    func test_threeKeysAreDistinctScreensPlusSettings() {
        XCTAssertEqual(ReviewHook.today.rawValue, "today")
        XCTAssertEqual(ReviewHook.log.rawValue, "log")
        XCTAssertEqual(ReviewHook.goals.rawValue, "goals")
        XCTAssertEqual(ReviewHook.settings.rawValue, "settings")
        XCTAssertEqual(ReviewHook.rehold.rawValue, "rehold")
        XCTAssertEqual(ReviewHook.today.pane, .desk)
        XCTAssertEqual(ReviewHook.log.pane, .review)
        XCTAssertEqual(ReviewHook.goals.pane, .rules)
        XCTAssertEqual(ReviewHook.settings.pane, .settings)
        XCTAssertNotEqual(ReviewHook.today.pane, ReviewHook.log.pane)
        XCTAssertNotEqual(ReviewHook.log.pane, ReviewHook.goals.pane)
        XCTAssertNotEqual(ReviewHook.today.pane, ReviewHook.goals.pane)
        XCTAssertNotEqual(ReviewHook.settings.pane, ReviewHook.today.pane)
        XCTAssertEqual(Set(DeskPane.allCases.map(\.rawValue)).count, 4)
        XCTAssertFalse(DeskPane.allCases.map(\.rawValue).contains("game"))
        XCTAssertNil(ClaimSheet.from(hook: .today))
        XCTAssertEqual(ClaimSheet.from(hook: .log), .review)
        XCTAssertEqual(ClaimSheet.from(hook: .goals), .rules)
        XCTAssertEqual(ClaimSheet.from(hook: .settings), .settings)
        XCTAssertEqual(ClaimSheet.from(hook: .rehold), .rehold)
        XCTAssertNotEqual(ClaimSheet.from(hook: .log), ClaimSheet.from(hook: .goals))

        var consumed = false
        XCTAssertEqual(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        consumed = false
        XCTAssertEqual(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .goals
        )
        consumed = false
        XCTAssertEqual(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "settings"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .settings
        )
        consumed = false
        XCTAssertEqual(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "review"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .log
        )
        consumed = false
        XCTAssertEqual(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "home"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        consumed = false
        XCTAssertEqual(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "rehold"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .rehold
        )
    }

    func test_unknownKeyIsIgnored() {
        var consumed = false
        XCTAssertNil(
            DeskLaunch.consume(
                arguments: ["-ReviewScreen", "aura"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        XCTAssertTrue(consumed)
    }
}
