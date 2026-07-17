import Domain
import Presentation
import XCTest
@testable import Awan

@MainActor
final class AppDependencyContainerTests: XCTestCase {
    func testContainerResolvesSchedulingDependencies() async throws {
        let container = AppDependencyContainer()
        let fetchZonesUseCase = try XCTUnwrap(
            container.resolver.resolve(FetchZonesUseCase.self)
        )
        let engine = container.resolver.resolve(ScheduleEngine.self)
        let timelineUseCases = container.resolver.resolve(ScheduleTimelineUseCases.self)
        let timelineViewModel = container.resolver.resolve(ScheduleTimelineViewModel.self)

        let zones = try await fetchZonesUseCase.execute()

        XCTAssertNotNil(engine)
        XCTAssertNotNil(timelineUseCases)
        XCTAssertNotNil(timelineViewModel)
        XCTAssertEqual(zones.map(\.name), ["Morning", "Work", "Study", "Personal"])
    }
}
