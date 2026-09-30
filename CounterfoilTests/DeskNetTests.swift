import XCTest
@testable import Counterfoil

final class DeskNetTests: XCTestCase {
    func test_userAgentIsThisAppAndCatalogIsOff() {
        XCTAssertEqual(
            DeskNet.userAgent,
            "Counterfoil/1.0 (iOS; +https://counterfoil-desk.pro)"
        )
        XCTAssertEqual(
            DeskNet.contactURL?.absoluteString,
            "https://counterfoil-desk.pro/contact-us"
        )
        XCTAssertFalse(DeskNet.catalogEnabled)
        XCTAssertEqual(DeskNet.lookupRetailCode("  848000111111  "), "848000111111")
        XCTAssertNil(DeskNet.lookupRetailCode("   "))
    }
}
