import Domain
import Foundation
import SwiftData
import XCTest
@testable import Data

final class SwiftDataLocalDataSourceTests: XCTestCase {
    func testTaskCRUDAndDependencyRoundTrip() async throws {
        let source = SwiftDataTaskDataSource(modelContainer: try makeContainer())
        let dependencyID = UUID()
        let task = try AwanTask(
            id: UUID(),
            title: "Task",
            duration: TaskDuration(minutes: 45),
            isSplittable: true,
            dependencyIDs: [dependencyID]
        )

        try await source.addTask(task)
        let fetched = try await source.fetchTask(id: task.id)
        XCTAssertEqual(fetched, task)

        let updated = try AwanTask(
            id: task.id,
            title: "Updated",
            duration: TaskDuration(minutes: 60),
            isSplittable: false,
            dependencyIDs: [dependencyID]
        )
        try await source.updateTask(updated)
        let updatedTasks = try await source.fetchTasks()
        XCTAssertEqual(updatedTasks, [updated])

        await XCTAssertThrowsErrorAsync {
            try await source.addTask(updated)
        }
        try await source.deleteTask(id: task.id)
        let remainingTasks = try await source.fetchTasks()
        XCTAssertTrue(remainingTasks.isEmpty)
    }

    func testTaskUpsertUpdatesMatchingTasksAndPreservesOtherDays() async throws {
        let source = SwiftDataTaskDataSource(modelContainer: try makeContainer())
        let retained = try AwanTask(
            id: UUID(),
            title: "Retained from another day",
            duration: TaskDuration(minutes: 30),
            isSplittable: false
        )
        let current = try AwanTask(
            id: UUID(),
            title: "Old title",
            duration: TaskDuration(minutes: 45),
            isSplittable: false
        )
        let updated = try AwanTask(
            id: current.id,
            title: "Updated title",
            duration: TaskDuration(minutes: 60),
            isSplittable: true
        )
        let inserted = try AwanTask(
            id: UUID(),
            title: "New current-day task",
            duration: TaskDuration(minutes: 20),
            isSplittable: false
        )
        try await source.addTask(retained)
        try await source.addTask(current)

        try await source.upsertTasks([updated, inserted])

        let tasksByID = Dictionary(
            uniqueKeysWithValues: try await source.fetchTasks().map { ($0.id, $0) }
        )
        XCTAssertEqual(tasksByID[retained.id], retained)
        XCTAssertEqual(tasksByID[current.id], updated)
        XCTAssertEqual(tasksByID[inserted.id], inserted)
    }

    func testTaskDependencyMutationsAndQueries() async throws {
        let source = SwiftDataTaskDataSource(modelContainer: try makeContainer())
        let repository = source
        let dependency = AwanTask(
            id: UUID(),
            title: "Dependency",
            duration: try TaskDuration(minutes: 30),
            isSplittable: false
        )
        let dependent = AwanTask(
            id: UUID(),
            title: "Dependent",
            duration: try TaskDuration(minutes: 30),
            isSplittable: false
        )
        try await repository.addTask(dependency)
        try await repository.addTask(dependent)

        try await repository.addDependency(
            taskID: dependent.id,
            dependsOnID: dependency.id
        )
        try await repository.addDependency(
            taskID: dependent.id,
            dependsOnID: dependency.id
        )

        let dependencies = try await repository.fetchDependencies(taskID: dependent.id)
        let dependents = try await repository.fetchDependents(taskID: dependency.id)
        XCTAssertEqual(dependencies, [dependency])
        XCTAssertEqual(dependents.map(\.id), [dependent.id])
        XCTAssertEqual(dependents.first?.dependencyIDs, [dependency.id])

        try await repository.removeDependency(
            taskID: dependent.id,
            dependsOnID: dependency.id
        )
        let dependenciesAfterRemoval = try await repository.fetchDependencies(
            taskID: dependent.id
        )
        XCTAssertTrue(dependenciesAfterRemoval.isEmpty)

        let missingDependencyID = UUID()
        await XCTAssertThrowsErrorAsync {
            try await repository.addDependency(
                taskID: dependent.id,
                dependsOnID: missingDependencyID
            )
        } verify: { error in
            XCTAssertEqual(
                error as? SchedulingError,
                .missingDependency(
                    taskID: dependent.id,
                    dependencyID: missingDependencyID
                )
            )
        }
    }

    func testAllPersistenceModelsRoundTripToDomain() throws {
        let dependencyIDs: Set<UUID> = [UUID(), UUID()]
        let task = AwanTask(
            id: UUID(),
            title: "Task",
            description: "Description",
            status: .inProgress,
            goalID: UUID(),
            zoneID: UUID(),
            duration: try TaskDuration(minutes: 75),
            isSplittable: true,
            mandatory: false,
            estimatedPoints: 8,
            dependencyIDs: dependencyIDs
        )
        XCTAssertEqual(try TaskModel(domain: task).toDomain(), task)

        let goal = Goal(
            id: UUID(),
            name: "Goal",
            description: "Description",
            status: .completed,
            deadline: Date(timeIntervalSince1970: 200),
            createdAt: Date(timeIntervalSince1970: 100)
        )
        XCTAssertEqual(try GoalModel(domain: goal).toDomain(), goal)

        let session = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: task.zoneID,
            timeRange: try TimeRange(
                start: Date(timeIntervalSince1970: 300),
                end: Date(timeIntervalSince1970: 600)
            ),
            blocking: true,
            status: .completed
        )
        XCTAssertEqual(try SessionModel(domain: session).toDomain(), session)

        let zone = try Zone(
            id: UUID(),
            name: "Work",
            color: ZoneColor(hex: "#123ABC"),
            startTime: LocalTime(hour: 9, minute: 15),
            endTime: LocalTime(hour: 17, minute: 45)
        )
        XCTAssertEqual(
            try ZoneModel(
                domain: zone,
                templateID: UUID(),
                templateOverrideID: nil
            ).toDomain(),
            zone
        )
    }

    func testMissingUpdateThrowsEntityNotFound() async throws {
        let source = SwiftDataGoalDataSource(modelContainer: try makeContainer())
        let goal = Goal(id: UUID(), name: "Goal", deadline: Date())

        await XCTAssertThrowsErrorAsync {
            try await source.updateGoal(goal)
        } verify: { error in
            XCTAssertEqual(error as? SchedulingError, .entityNotFound(id: goal.id))
        }
    }

    func testSessionDeleteByTaskID() async throws {
        let source = SwiftDataSessionDataSource(modelContainer: try makeContainer())
        let taskID = UUID()
        let matching = try session(taskID: taskID)
        let other = try session(taskID: UUID())
        try await source.addSession(matching)
        try await source.addSession(other)

        try await source.deleteSessions(taskID: taskID)

        let sessions = try await source.fetchSessions()
        XCTAssertEqual(sessions, [other])
    }

    func testSessionReplacementForDayLeavesOtherDaysUntouched() async throws {
        let source = SwiftDataSessionDataSource(modelContainer: try makeContainer())
        let day = try localDate(year: 2026, month: 7, day: 24)
        let followingDay = try localDate(year: 2026, month: 7, day: 25)
        let stale = try session(taskID: UUID(), start: day)
        let retained = try session(taskID: UUID(), start: followingDay)
        let replacement = try session(taskID: UUID(), start: day.addingTimeInterval(3_600))
        try await source.addSession(stale)
        try await source.addSession(retained)

        try await source.replaceSessions(
            [replacement],
            forDay: "2026-07-24",
            timeZoneID: TimeZone.current.identifier
        )

        let sessions = try await source.fetchSessions()
        XCTAssertEqual(Set(sessions.map(\.id)), [retained.id, replacement.id])
    }

    func testDuplicateSessionAndMissingSessionUpdateFollowMutationRules() async throws {
        let source = SwiftDataSessionDataSource(modelContainer: try makeContainer())
        let persisted = try session(taskID: UUID())
        try await source.addSession(persisted)

        await XCTAssertThrowsErrorAsync {
            try await source.addSession(persisted)
        } verify: { error in
            XCTAssertEqual(
                error as? SchedulingPersistenceError,
                .duplicateID(persisted.id)
            )
        }

        let missing = try session(taskID: UUID())
        await XCTAssertThrowsErrorAsync {
            try await source.updateSession(missing)
        } verify: { error in
            XCTAssertEqual(error as? SchedulingError, .entityNotFound(id: missing.id))
        }

        try await source.deleteSession(id: UUID())
        let sessions = try await source.fetchSessions()
        XCTAssertEqual(sessions, [persisted])
    }

    func testDeleteAllClearsTasksGoalsAndSessions() async throws {
        let container = try makeContainer()
        let taskSource = SwiftDataTaskDataSource(modelContainer: container)
        let goalSource = SwiftDataGoalDataSource(modelContainer: container)
        let sessionSource = SwiftDataSessionDataSource(modelContainer: container)
        let task = AwanTask(
            id: UUID(),
            duration: try TaskDuration(minutes: 30),
            isSplittable: false
        )
        let goal = Goal(id: UUID(), name: "Goal", deadline: Date())
        let session = try session(taskID: task.id)
        try await taskSource.addTask(task)
        try await goalSource.addGoal(goal)
        try await sessionSource.addSession(session)

        try await taskSource.deleteAllTasks()
        try await goalSource.deleteAllGoals()
        try await sessionSource.deleteAllSessions()

        let tasks = try await taskSource.fetchTasks()
        let goals = try await goalSource.fetchGoals()
        let sessions = try await sessionSource.fetchSessions()
        XCTAssertTrue(tasks.isEmpty)
        XCTAssertTrue(goals.isEmpty)
        XCTAssertTrue(sessions.isEmpty)
    }

    func testSimulationResetLeavesTemplatesAndZonesUntouched() async throws {
        let container = try makeContainer()
        let taskSource = SwiftDataTaskDataSource(modelContainer: container)
        let goalSource = SwiftDataGoalDataSource(modelContainer: container)
        let sessionSource = SwiftDataSessionDataSource(modelContainer: container)
        let zoneSource = SwiftDataZoneDataSource(modelContainer: container)
        let templateSource = SwiftDataTemplateDataSource(modelContainer: container)
        let overrideSource = SwiftDataTemplateOverrideDataSource(modelContainer: container)
        let zone = try Zone(
            id: UUID(),
            name: "Work",
            color: ZoneColor(hex: "#FFFFFF"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
        let day = try localDate(year: 2026, month: 7, day: 20)
        try await templateSource.addTemplate(
            TemplateData(id: UUID(), name: "Monday", weekDays: [2], zones: [zone])
        )

        let task = AwanTask(
            id: UUID(),
            duration: try TaskDuration(minutes: 30),
            isSplittable: false
        )
        let goal = Goal(id: UUID(), name: "Goal", deadline: day)
        let session = try session(taskID: task.id)
        let taskRepository = LocalTaskRepositoryStub(
            dataSource: taskSource,
            sessionDataSource: sessionSource
        )
        let goalRepository = DefaultGoalRepository(localDataSource: goalSource)
        let sessionRepository = LocalSessionRepositoryStub(dataSource: sessionSource)
        let zoneRepository = makeZoneRepository(
            zoneDataSource: zoneSource,
            templateDataSource: templateSource,
            templateOverrideDataSource: overrideSource
        )
        _ = try await taskRepository.addTask(
            task,
            startsAt: nil,
            durationMinutes: task.duration.minutes,
            timeZoneID: TimeZone.current.identifier
        )
        try await goalRepository.addGoal(goal)
        try await sessionRepository.addSession(session)
        let workspaceProvider = DefaultScheduleWorkspaceProvider(
            zoneRepository: zoneRepository,
            goalRepository: goalRepository,
            taskRepository: taskRepository,
            sessionRepository: sessionRepository
        )
        let reset = ResetScheduleSimulationUseCaseImpl(
            workspaceProvider: workspaceProvider,
            taskRepository: taskRepository,
            goalRepository: goalRepository,
            sessionRepository: sessionRepository
        )

        let workspace = try await reset.execute(on: day)

        XCTAssertEqual(workspace.zones, [zone])
        XCTAssertTrue(workspace.tasks.isEmpty)
        XCTAssertTrue(workspace.goals.isEmpty)
        XCTAssertTrue(workspace.sessions.isEmpty)
        let persistedTemplate = try await templateSource.fetchTemplate(forWeekDay: 2)
        XCTAssertEqual(persistedTemplate?.zones, [zone])
    }

    func testInvalidRawValuesFailMapping() throws {
        let task = TaskModel(
            id: UUID(),
            title: "Task",
            taskDescription: nil,
            statusRaw: "unknown",
            goalID: nil,
            zoneID: nil,
            estimatedDurationMinutes: 30,
            allowTaskSplitting: false,
            mandatory: true,
            estimatedPoints: 0,
            dependencyIDs: []
        )
        XCTAssertThrowsError(try task.toDomain()) { error in
            XCTAssertEqual(error as? SchedulingError, .invalidTaskStatus(raw: "unknown"))
        }

        let goal = GoalModel(
            id: UUID(),
            title: "Goal",
            goalDescription: nil,
            statusRaw: "unknown",
            deadline: Date(),
            createdAt: Date()
        )
        XCTAssertThrowsError(try goal.toDomain())

        let session = SessionModel(
            id: UUID(),
            taskID: UUID(),
            zoneID: nil,
            startDate: Date(timeIntervalSince1970: 100),
            endDate: Date(timeIntervalSince1970: 200),
            blocking: false,
            statusRaw: "unknown"
        )
        XCTAssertThrowsError(try session.toDomain()) { error in
            XCTAssertEqual(error as? SchedulingError, .invalidSessionStatus(raw: "unknown"))
        }
    }

    func testInvalidPersistedTimesFailMapping() {
        let instant = Date(timeIntervalSince1970: 100)
        let session = SessionModel(
            id: UUID(),
            taskID: UUID(),
            zoneID: nil,
            startDate: instant,
            endDate: instant,
            blocking: false,
            statusRaw: "planned"
        )
        XCTAssertThrowsError(try session.toDomain()) { error in
            XCTAssertEqual(error as? SchedulingError, .invalidTimeRange)
        }

        let zone = ZoneModel(
            id: UUID(),
            name: "Invalid",
            colorHex: "#FFFFFF",
            startHour: 24,
            startMinute: 0,
            endHour: 17,
            endMinute: 0,
            templateID: UUID(),
            templateOverrideID: nil
        )
        XCTAssertThrowsError(try zone.toDomain()) { error in
            XCTAssertEqual(
                error as? SchedulingError,
                .invalidLocalTime(hour: 24, minute: 0)
            )
        }
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func session(taskID: UUID, start: Date = Date()) throws -> Session {
        return Session(
            id: UUID(),
            taskID: taskID,
            zoneID: nil,
            timeRange: try TimeRange(
                start: start,
                end: start.addingTimeInterval(1_800)
            ),
            blocking: false,
            status: .planned
        )
    }

    private func localDate(year: Int, month: Int, day: Int) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        guard let date = calendar.date(
            from: DateComponents(year: year, month: month, day: day)
        ) else {
            throw SchedulingError.invalidTimeRange
        }
        return date
    }
}

func XCTAssertThrowsErrorAsync(
    _ expression: () async throws -> Void,
    verify: (Error) -> Void = { _ in },
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await expression()
        XCTFail("Expected error", file: file, line: line)
    } catch {
        verify(error)
    }
}
