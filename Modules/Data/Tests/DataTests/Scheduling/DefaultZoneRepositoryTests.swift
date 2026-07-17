import Domain
import XCTest
@testable import Data

final class DefaultZoneRepositoryTests: XCTestCase {
    func testFixedRepositoryReturnsConfiguredZones() async throws {
        let repository = DefaultZoneRepository(localDataSource: FixedZoneDataSource())

        let zones = try await repository.fetchZones()

        XCTAssertEqual(zones.map(\.name), ["Morning", "Work", "Study", "Personal"])
        XCTAssertEqual(zones.map(\.startTime.hour), [7, 9, 18, 21])
        XCTAssertEqual(zones.map(\.endTime.hour), [9, 17, 21, 0])
        XCTAssertEqual(Set(zones.map(\.id)).count, 4)
    }
}
