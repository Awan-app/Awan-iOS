import Data
import Domain
import Presentation
import SwiftData
import XCTest
@testable import Awan

@MainActor
final class AppDependencyContainerTests: XCTestCase {
    func testContainerResolvesSchedulingDependencies() async throws {
        let schema = SchedulingPersistence.schema
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: schema, configurations: [config])
        let container = AppDependencyContainer(modelContainer: modelContainer)
        let fetchZonesUseCase = try XCTUnwrap(
            container.resolver.resolve(FetchZonesUseCase.self)
        )
        let engine = container.resolver.resolve(ScheduleEngine.self)
        let timelineUseCases = container.resolver.resolve(ScheduleTimelineUseCases.self)
        let timelineViewModel = container.resolver.resolve(ScheduleTimelineViewModel.self)

        let zones = try await fetchZonesUseCase.execute(for: Date())

        XCTAssertNotNil(engine)
        XCTAssertNotNil(timelineUseCases)
        XCTAssertNotNil(timelineViewModel)
        XCTAssertFalse(zones.isEmpty)
    }
}
