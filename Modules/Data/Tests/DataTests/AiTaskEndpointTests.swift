import Foundation
import XCTest
import AwaNetwork
@testable import Data

final class AiTaskEndpointTests: XCTestCase {
    func testCreateAITaskEndpointMatchesBackendContract() throws {
        let requestDTO = CreateAITaskRequestDTO(text: "i need to go to gym at 10 pm.")
        let endpoint = AiTaskEndpoint.createAITask(requestDTO)

        XCTAssertEqual(endpoint.path, "/ai/task-create")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertNil(endpoint.queryParameters)
    }

    func testCreateAITaskRequestDTOEncodesTextPayload() throws {
        let requestDTO = CreateAITaskRequestDTO(text: "i need to go to gym at 10 pm.")
        let data = try JSONEncoder().encode(requestDTO)
        let jsonObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        XCTAssertEqual(jsonObject["text"] as? String, "i need to go to gym at 10 pm.")
        XCTAssertNil(jsonObject["title"])
    }
}
