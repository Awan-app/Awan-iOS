import Domain
import Foundation
import XCTest
@testable import Data

final class InMemoryLocalDataSourceTests: XCTestCase {
    func testPreviewSourcesExposeLinkedMockData() async throws {
        let sources = InMemorySchedulingDataSources(data: .preview)

        let goals = await sources.goal.fetchGoals()
        let tasks = await sources.task.fetchTasks()
        let sessions = await sources.session.fetchSessions()

        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(sessions.count, 1)

        let dependentTask = try XCTUnwrap(tasks.first(where: { !$0.dependencyIDs.isEmpty }))
        let dependencies = try await sources.task.fetchDependencies(taskID: dependentTask.id)
        XCTAssertEqual(dependencies.map(\.id), Array(dependentTask.dependencyIDs))
        XCTAssertEqual(dependentTask.goalID, goals.first?.id)
        XCTAssertEqual(sessions.first?.taskID, dependentTask.id)
    }

    func testPreviewOverrideAndWeekdayTemplatesResolveThroughRepository() async throws {
        let sources = InMemorySchedulingDataSources(data: .preview)
        let repository = DefaultZoneRepository(
            zoneDataSource: sources.zone,
            templateDataSource: sources.template,
            templateOverrideDataSource: sources.templateOverride
        )
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: today))

        let todayZones = try await repository.fetchZones(for: today)
        let tomorrowZones = try await repository.fetchZones(for: tomorrow)

        XCTAssertEqual(todayZones.map(\.startTime.hour), [8, 10, 17, 21])
        XCTAssertEqual(todayZones.map(\.endTime.hour), [10, 17, 21, 0])
        XCTAssertEqual(tomorrowZones.count, 4)
        XCTAssertTrue(tomorrowZones.allSatisfy { $0.name.hasPrefix("Special") })
    }

    func testUpdatingZoneIsVisibleThroughSharedTemplateSource() async throws {
        let sources = InMemorySchedulingDataSources(data: .preview)
        let weekDay = Calendar.current.component(.weekday, from: Date())
        let template = try await sources.template.fetchTemplate(forWeekDay: weekDay)
        let original = try XCTUnwrap(template?.zones.first)
        let updated = Zone(
            id: original.id,
            name: "Updated Mock Zone",
            color: original.color,
            startTime: original.startTime,
            endTime: original.endTime
        )

        try await sources.zone.updateZone(updated)

        let resolved = try await sources.template.fetchTemplate(forWeekDay: weekDay)?.zones
        XCTAssertEqual(resolved?.first(where: { $0.id == original.id })?.name, updated.name)
    }

    func testTaskMutationsStayIsolatedInTaskSource() async throws {
        let sources = InMemorySchedulingDataSources(data: SchedulingMockData())
        let task = try AwanTask(
            id: UUID(),
            title: "Temporary mock task",
            duration: TaskDuration(minutes: 25),
            isSplittable: false
        )

        try await sources.task.addTask(task)
        let insertedTask = await sources.task.fetchTask(id: task.id)
        XCTAssertEqual(insertedTask, task)
        await sources.task.deleteTask(id: task.id)
        let deletedTask = await sources.task.fetchTask(id: task.id)
        let goals = await sources.goal.fetchGoals()
        XCTAssertNil(deletedTask)
        XCTAssertTrue(goals.isEmpty)
    }
}
