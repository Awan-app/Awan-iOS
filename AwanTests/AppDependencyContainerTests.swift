import Domain
import XCTest
@testable import Awan

final class AppDependencyContainerTests: XCTestCase {
    func testContainerResolvesSchedulingDependencies() async throws {
        let container = AppDependencyContainer()
        let fetchZonesUseCase = try XCTUnwrap(
            container.resolver.resolve(FetchZonesUseCase.self)
        )
        let engine = container.resolver.resolve(ScheduleEngine.self)

        let zones = try await fetchZonesUseCase.execute()

        XCTAssertNotNil(engine)
        XCTAssertEqual(zones.map(\.name), ["Morning", "Work", "Study", "Personal"])
    }
}
