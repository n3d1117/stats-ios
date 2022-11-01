@testable import Networking
import XCTest

final class APITests: XCTestCase {
    func testGenerateRequest() throws {
        let request = API.generateRequest(.GET, .data)
        let url = try XCTUnwrap(request.url)
        XCTAssertEqual(url.absoluteString, "https://edoardo.fyi/data.json")
    }
}
