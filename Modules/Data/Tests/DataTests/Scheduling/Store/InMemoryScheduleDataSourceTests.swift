import XCTest
import Domain
@testable import Data

final class InMemoryScheduleDataSourceTests: XCTestCase {
    func testFetchInboxTasks() async throws {
        let dataSource = InMemoryScheduleDataSource()
        let t1 = AwanTask(id: UUID(), title: "Inbox 1", duration: try TaskDuration(minutes: 30), isSplittable: false, goalID: nil)
        let t2 = AwanTask(id: UUID(), title: "Goal Task", duration: try TaskDuration(minutes: 30), isSplittable: false, goalID: UUID())
        try await dataSource.addTask(TaskRecord(domain: t1))
        try await dataSource.addTask(TaskRecord(domain: t2))
        
        let inbox = try await dataSource.fetchInboxTasks()
        XCTAssertEqual(inbox.count, 1)
        XCTAssertEqual(inbox.first?.id, t1.id)
    }

    func testFetchTasksForGoal() async throws {
        let dataSource = InMemoryScheduleDataSource()
        let goalId = UUID()
        let t1 = AwanTask(id: UUID(), title: "G1", duration: try TaskDuration(minutes: 30), isSplittable: false, goalID: goalId)
        let t2 = AwanTask(id: UUID(), title: "G2", duration: try TaskDuration(minutes: 30), isSplittable: false, goalID: UUID())
        try await dataSource.addTask(TaskRecord(domain: t1))
        try await dataSource.addTask(TaskRecord(domain: t2))
        
        let tasks = try await dataSource.fetchTasks(goalID: goalId)
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.id, t1.id)
    }

    func testAddTasksBulkInsert() async throws {
        let dataSource = InMemoryScheduleDataSource()
        let tasks = [
            AwanTask(id: UUID(), duration: try TaskDuration(minutes: 10), isSplittable: false),
            AwanTask(id: UUID(), duration: try TaskDuration(minutes: 20), isSplittable: false)
        ]
        try await dataSource.addTasks(tasks)
        
        let stored = try await dataSource.fetchTasks()
        XCTAssertEqual(stored.count, 2)
    }

    func testAddAndRemoveDependency() async throws {
        let dataSource = InMemoryScheduleDataSource()
        let taskID = UUID()
        let depID = UUID()
        let t1 = AwanTask(id: taskID, duration: try TaskDuration(minutes: 10), isSplittable: false)
        try await dataSource.addTask(TaskRecord(domain: t1))
        
        try await dataSource.addDependency(taskID: taskID, dependsOnID: depID)
        let deps = try await dataSource.fetchDependencies(taskID: taskID)
        XCTAssertEqual(try await dataSource.fetchTask(id: taskID)?.dependencyIDs.contains(depID), true)
        
        try await dataSource.removeDependency(taskID: taskID, dependsOnID: depID)
        XCTAssertEqual(try await dataSource.fetchTask(id: taskID)?.dependencyIDs.contains(depID), false)
    }

    func testFetchDependents() async throws {
        let dataSource = InMemoryScheduleDataSource()
        let depID = UUID()
        let t1 = AwanTask(id: UUID(), duration: try TaskDuration(minutes: 10), isSplittable: false, dependencyIDs: [depID])
        let t2 = AwanTask(id: UUID(), duration: try TaskDuration(minutes: 10), isSplittable: false, dependencyIDs: [depID])
        let t3 = AwanTask(id: UUID(), duration: try TaskDuration(minutes: 10), isSplittable: false)
        try await dataSource.addTask(TaskRecord(domain: t1))
        try await dataSource.addTask(TaskRecord(domain: t2))
        try await dataSource.addTask(TaskRecord(domain: t3))
        
        let dependents = try await dataSource.fetchDependents(taskID: depID)
        XCTAssertEqual(dependents.count, 2)
        XCTAssertTrue(dependents.contains { $0.id == t1.id })
        XCTAssertTrue(dependents.contains { $0.id == t2.id })
    }

    func testMoveTaskReordersSiblings() async throws {
        let dataSource = InMemoryScheduleDataSource()
        let goalID = UUID()
        
        // Setup siblings
        let ids = (0..<4).map { _ in UUID() }
        for (i, id) in ids.enumerated() {
            let record = TaskRecord(id: id, title: "T\(i)", description: nil, statusRaw: "pending", goalID: goalID, zoneID: nil, estimatedDurationMinutes: 10, allowTaskSplitting: false, mandatory: true, estimatedPoints: 0, dependencyIDs: [], order: i)
            try await dataSource.addTask(record)
        }
        
        // Move task 3 to position 1
        try await dataSource.moveTask(id: ids[3], toGoalID: goalID, toZoneID: nil, newOrder: 1)
        
        // Expected order: ids[0] (0), ids[3] (1), ids[1] (2), ids[2] (3)
        let tasks = try await dataSource.fetchTasks().sorted { $0.order < $1.order }
        
        XCTAssertEqual(tasks[0].id, ids[0])
        XCTAssertEqual(tasks[0].order, 0)
        
        XCTAssertEqual(tasks[1].id, ids[3])
        XCTAssertEqual(tasks[1].order, 1)
        
        XCTAssertEqual(tasks[2].id, ids[1])
        XCTAssertEqual(tasks[2].order, 2)
        
        XCTAssertEqual(tasks[3].id, ids[2])
        XCTAssertEqual(tasks[3].order, 3)
    }
}
