import XCTest
@testable import Counterfoil

final class CounterfoilTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: CounterfoilApp.self), "CounterfoilApp")
    }
}
