import XCTest
@testable import PrimaryCoreNetwork

final class PrimaryCoreNetworkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PrimaryCoreNetwork().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
