import Domain
import Foundation
import SwiftData
import XCTest
@testable import Data

final class ScheduleWorkspaceIntegrationTests: XCTestCase {
    private let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    func testTaskCRUDSchedulesInSelectedDaysZone() async throws {
        let useCase = try await makeSystem().useCase
        let workspace = try await useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let selectedDay = date(day: 20)

        let created = try await useCase.addTask(
            CreateTaskRequest(
                title: "Build timeline",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: selectedDay,
                timeZone: timeZone
            )
        )

        let task = try XCTUnwrap(created.workspace.tasks.first)
        let session = try XCTUnwrap(created.workspace.sessions.first)
        XCTAssertEqual(task.title, "Build timeline")
        XCTAssertEqual(session.taskID, task.id)
        XCTAssertEqual(session.timeRange.start, date(day: 20, hour: 9))
        XCTAssertFalse(session.blocking)

        let updated = try await useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: "Polish timeline",
                minutes: 210,
                zoneID: task.zoneID,
                isSplittable: true,
                day: selectedDay
            )
        )
        XCTAssertEqual(updated.workspace.tasks.first?.title, "Polish timeline")
        XCTAssertEqual(updated.workspace.sessions.first?.timeRange.start, date(day: 20, hour: 9))
        XCTAssertEqual(updated.workspace.sessions.first?.timeRange.end, date(day: 20, hour: 12, minute: 30))

        let deleted = try await useCase.deleteTask(id: task.id)
        XCTAssertTrue(deleted.tasks.isEmpty)
        XCTAssertTrue(deleted.sessions.isEmpty)
    }

    func testSevenTaskGoalCreatesSequentialChainAcrossSevenDays() async throws {
        let useCase = try await makeSystem().useCase
        let workspace = try await useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let startDay = date(day: 20)

        let result = try await useCase.createSevenTaskGoal(
            CreateSevenTaskGoalRequest(
                name: "Launch portfolio",
                zoneID: workZone.id,
                taskDurationMinutes: 60,
                startDay: startDay,
                timeZone: timeZone
            )
        )

        XCTAssertNil(result.nudge)
        XCTAssertEqual(result.workspace.goals.count, 1)
        XCTAssertEqual(result.workspace.tasks.count, 7)
        XCTAssertEqual(result.workspace.sessions.count, 7)

        let tasks = result.workspace.tasks
        XCTAssertTrue(tasks[0].dependencyIDs.isEmpty)
        for index in 1..<tasks.count {
            XCTAssertEqual(tasks[index].dependencyIDs, [tasks[index - 1].id])
        }

        let sessionDays = result.workspace.sessions
            .sorted { $0.timeRange.start < $1.timeRange.start }
            .map { calendar.component(.day, from: $0.timeRange.start) }
        XCTAssertEqual(sessionDays, [20, 21, 22, 23, 24, 25, 26])
    }

    func testOverlapScenarioOnlyChangesAfterExplicitResolution() async throws {
        let useCase = try await makeSystem().useCase

        let simulated = try await useCase.simulate(
            .overlap,
            on: date(day: 20),
            in: timeZone
        )

        guard case let .overlap(firstID, secondID) = simulated.nudge else {
            return XCTFail("Expected an overlap nudge")
        }
        let originalSecond = try XCTUnwrap(
            simulated.workspace.sessions.first { $0.id == secondID }
        )
        let originalFirst = try XCTUnwrap(
            simulated.workspace.sessions.first { $0.id == firstID }
        )
        XCTAssertEqual(originalSecond.timeRange.start, date(day: 20, hour: 10, minute: 30))

        let resolved = try await useCase.resolve(
            .separateSessions(firstSessionID: firstID, secondSessionID: secondID)
        )
        let first = try XCTUnwrap(resolved.workspace.sessions.first { $0.id == firstID })
        let second = try XCTUnwrap(resolved.workspace.sessions.first { $0.id == secondID })
        XCTAssertEqual(second.timeRange.start, first.timeRange.end)
        XCTAssertEqual(second.timeRange, originalSecond.timeRange)
        XCTAssertNotEqual(first.timeRange, originalFirst.timeRange)
        XCTAssertTrue(first.blocking)
    }

    func testOverflowScenarioOffersApprovalCandidatesWithoutSchedulingTomorrow() async throws {
        let useCase = try await makeSystem().useCase

        let result = try await useCase.simulate(
            .zoneOverflow,
            on: date(day: 20),
            in: timeZone
        )

        guard case let .schedulingIssue(issue) = result.nudge else {
            return XCTFail("Expected a scheduling issue nudge")
        }
        XCTAssertEqual(issue.availableMinutes, 30)
        XCTAssertTrue(issue.resolutionCandidates.allSatisfy(\.requiresUserApproval))
        XCTAssertTrue(issue.resolutionCandidates.contains { $0.kind == .splitAcrossDays })
        XCTAssertTrue(issue.resolutionCandidates.contains { $0.kind == .scheduleNextAvailableDay })
        XCTAssertEqual(result.workspace.sessions.count, 1)
        XCTAssertTrue(
            result.workspace.sessions.allSatisfy {
                calendar.isDate($0.timeRange.start, inSameDayAs: date(day: 20))
            }
        )

        let nextDayCandidate = try XCTUnwrap(
            issue.resolutionCandidates.first { $0.kind == .scheduleNextAvailableDay }
        )
        let approved = try await useCase.resolve(.applyCandidate(nextDayCandidate))
        let approvedSession = try XCTUnwrap(
            approved.workspace.sessions.first { $0.taskID == issue.taskID }
        )
        XCTAssertTrue(
            calendar.isDate(approvedSession.timeRange.start, inSameDayAs: date(day: 21))
        )
    }

    func testMoveSecondOverlapResolutionKeepsFirstSessionFixed() async throws {
        let useCase = try await makeSystem().useCase
        let simulated = try await useCase.simulate(
            .overlap,
            on: date(day: 20),
            in: timeZone
        )
        guard case let .overlap(firstID, secondID) = simulated.nudge else {
            return XCTFail("Expected an overlap nudge")
        }
        let originalFirst = try XCTUnwrap(
            simulated.workspace.sessions.first { $0.id == firstID }
        )

        let resolved = try await useCase.resolve(
            .moveSecondSessionAfterFirst(firstSessionID: firstID, secondSessionID: secondID)
        )
        let first = try XCTUnwrap(resolved.workspace.sessions.first { $0.id == firstID })
        let second = try XCTUnwrap(resolved.workspace.sessions.first { $0.id == secondID })
        XCTAssertEqual(first.timeRange, originalFirst.timeRange)
        XCTAssertEqual(second.timeRange.start, first.timeRange.end)
        XCTAssertTrue(second.blocking)
    }

    func testMissedChainResolutionsShiftStackAndCutDependencyWithoutLeavingGoal() async throws {
        let useCase = try await makeSystem().useCase
        let simulated = try await useCase.simulate(
            .missedDependencyChain,
            on: date(day: 20),
            in: timeZone
        )
        guard case let .missedDependencyChain(goalID, missedID, _) = simulated.nudge else {
            return XCTFail("Expected a missed dependency chain nudge")
        }
        let originalDeadline = try XCTUnwrap(
            simulated.workspace.goals.first { $0.id == goalID }?.deadline
        )
        let originalMissedStart = try XCTUnwrap(
            simulated.workspace.sessions.first { $0.taskID == missedID }?.timeRange.start
        )

        let shifted = try await useCase.resolve(
            .shiftDependencyChain(goalID: goalID, timeZone: timeZone)
        )
        let shiftedDeadline = try XCTUnwrap(
            shifted.workspace.goals.first { $0.id == goalID }?.deadline
        )
        let shiftedMissedStart = try XCTUnwrap(
            shifted.workspace.sessions.first { $0.taskID == missedID }?.timeRange.start
        )
        XCTAssertEqual(calendar.dateComponents([.day], from: originalDeadline, to: shiftedDeadline).day, 1)
        XCTAssertEqual(calendar.dateComponents([.day], from: originalMissedStart, to: shiftedMissedStart).day, 1)

        let stackedScenario = try await useCase.simulate(
            .missedDependencyChain,
            on: date(day: 20),
            in: timeZone
        )
        guard case let .missedDependencyChain(_, stackedMissedID, stackedSuccessorID) = stackedScenario.nudge else {
            return XCTFail("Expected a missed dependency chain nudge")
        }
        let stacked = try await useCase.resolve(
            .stackMissedAndSuccessor(
                missedTaskID: stackedMissedID,
                successorTaskID: stackedSuccessorID
            )
        )
        let missedSession = try XCTUnwrap(
            stacked.workspace.sessions.first { $0.taskID == stackedMissedID }
        )
        let successorSession = try XCTUnwrap(
            stacked.workspace.sessions.first { $0.taskID == stackedSuccessorID }
        )
        XCTAssertEqual(missedSession.timeRange, successorSession.timeRange)
        XCTAssertEqual(missedSession.status, .planned)
        XCTAssertTrue(missedSession.blocking)

        let independentScenario = try await useCase.simulate(
            .missedDependencyChain,
            on: date(day: 20),
            in: timeZone
        )
        guard case let .missedDependencyChain(independentGoalID, dependencyID, taskID) = independentScenario.nudge else {
            return XCTFail("Expected a missed dependency chain nudge")
        }
        let independent = try await useCase.resolve(
            .makeTaskIndependent(taskID: taskID, dependencyID: dependencyID)
        )
        let task = try XCTUnwrap(independent.workspace.tasks.first { $0.id == taskID })
        XCTAssertFalse(task.dependencyIDs.contains(dependencyID))
        XCTAssertEqual(task.goalID, independentGoalID)
        XCTAssertNotNil(independent.workspace.goals.first { $0.id == independentGoalID })
    }

    func testZoneReconfigurationCanReplanOrRestoreWithoutMovingSilently() async throws {
        let useCase = try await makeSystem().useCase
        let simulated = try await useCase.simulate(
            .zoneReconfiguration,
            on: date(day: 20),
            in: timeZone
        )
        guard case let .zoneReconfigured(zoneID, _, sessionIDs) = simulated.nudge else {
            return XCTFail("Expected a zone reconfiguration nudge")
        }
        let unchangedSession = try XCTUnwrap(
            simulated.workspace.sessions.first { sessionIDs.contains($0.id) }
        )
        XCTAssertEqual(unchangedSession.timeRange.start, date(day: 20, hour: 9))
        XCTAssertEqual(simulated.workspace.zones.first { $0.id == zoneID }?.startTime.hour, 10)

        let replanned = try await useCase.resolve(
            .replanSessionsForZone(
                zoneID: zoneID,
                sessionIDs: sessionIDs,
                timeZone: timeZone
            )
        )
        let movedSession = try XCTUnwrap(
            replanned.workspace.sessions.first { sessionIDs.contains($0.id) }
        )
        XCTAssertEqual(movedSession.timeRange.start, date(day: 20, hour: 10))
        XCTAssertFalse(movedSession.blocking)

        let restoreScenario = try await useCase.simulate(
            .zoneReconfiguration,
            on: date(day: 20),
            in: timeZone
        )
        guard case let .zoneReconfigured(_, zoneToRestore, _) = restoreScenario.nudge else {
            return XCTFail("Expected a zone reconfiguration nudge")
        }
        let restored = try await useCase.resolve(.restoreZone(zoneToRestore))
        XCTAssertEqual(
            restored.workspace.zones.first { $0.id == zoneToRestore.id },
            zoneToRestore
        )
    }

    func testTitleOnlyEditKeepsExistingSessionIdentityAndRange() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Draft",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let originalSession = try XCTUnwrap(created.workspace.sessions.first)

        let updated = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: "Renamed",
                minutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                day: date(day: 20)
            )
        )

        let session = try XCTUnwrap(updated.workspace.sessions.first)
        XCTAssertEqual(updated.workspace.tasks.first?.title, "Renamed")
        XCTAssertEqual(session.id, originalSession.id)
        XCTAssertEqual(session.timeRange, originalSession.timeRange)
    }

    func testReducingEngineManagedTaskRebuildsShorterSession() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Long quest",
                durationMinutes: 210,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let originalSessionID = try XCTUnwrap(created.workspace.sessions.first?.id)

        let updated = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                day: date(day: 20)
            )
        )

        let session = try XCTUnwrap(updated.workspace.sessions.first)
        XCTAssertNotEqual(session.id, originalSessionID)
        XCTAssertEqual(session.timeRange.start, date(day: 20, hour: 9))
        XCTAssertEqual(session.timeRange.end, date(day: 20, hour: 10))
    }

    func testEngineManagedZoneEditReplansInsideNewZone() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let studyZone = try XCTUnwrap(workspace.zones.first { $0.name == "Study" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Change zone",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)

        let updated = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 60,
                zoneID: studyZone.id,
                isSplittable: false,
                day: date(day: 20)
            )
        )

        let session = try XCTUnwrap(updated.workspace.sessions.first)
        XCTAssertEqual(session.zoneID, studyZone.id)
        XCTAssertEqual(session.timeRange.start, date(day: 20, hour: 18))
        XCTAssertEqual(session.timeRange.end, date(day: 20, hour: 19))
    }

    func testCompletedSessionIsImmutableAndCountsTowardEditedDuration() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Completed work",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let original = try XCTUnwrap(created.workspace.sessions.first)
        let completed = Session(
            id: original.id,
            taskID: original.taskID,
            zoneID: original.zoneID,
            timeRange: original.timeRange,
            blocking: original.blocking,
            status: .completed
        )
        try await system.sessionRepository.updateSession(completed)

        let increased = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 120,
                zoneID: workZone.id,
                isSplittable: false,
                day: date(day: 20)
            )
        )
        let preserved = try XCTUnwrap(increased.workspace.sessions.first { $0.id == original.id })
        XCTAssertEqual(preserved, completed)
        XCTAssertEqual(increased.workspace.sessions.count, 2)

        let reduced = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 30,
                zoneID: workZone.id,
                isSplittable: false,
                day: date(day: 20)
            )
        )
        guard case let .fixedSessionOverAllocation(_, _, _, _, _, canTrim, _, _) = reduced.nudge else {
            return XCTFail("Expected completed-time informational nudge")
        }
        XCTAssertFalse(canTrim)
        XCTAssertEqual(reduced.workspace.sessions, [completed])
    }

    func testBlockingSessionIncreaseExtendsExistingSession() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Sacred quest",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let original = try XCTUnwrap(created.workspace.sessions.first)
        let fixedRange = try TimeRange(
            start: date(day: 20, hour: 10),
            end: date(day: 20, hour: 11)
        )
        _ = try await system.useCase.moveSession(
            MoveSessionRequest(
                sessionID: original.id,
                newTimeRange: fixedRange,
                selectedDay: fixedRange.start
            )
        )

        let updated = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 180,
                zoneID: workZone.id,
                isSplittable: false,
                blocking: true,
                day: date(day: 20)
            )
        )

        let session = try XCTUnwrap(updated.workspace.sessions.first)
        XCTAssertEqual(updated.workspace.sessions.count, 1)
        XCTAssertEqual(session.id, original.id)
        XCTAssertEqual(session.timeRange.start, fixedRange.start)
        XCTAssertEqual(session.timeRange.end, date(day: 20, hour: 13))
        XCTAssertTrue(session.blocking)
    }

    func testTaskDetailsCanReleaseBlockingSessionBackToEngine() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Release fixed time",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let original = try XCTUnwrap(created.workspace.sessions.first)
        _ = try await system.useCase.moveSession(
            MoveSessionRequest(
                sessionID: original.id,
                newTimeRange: try TimeRange(
                    start: date(day: 20, hour: 13),
                    end: date(day: 20, hour: 14)
                ),
                selectedDay: date(day: 20)
            )
        )

        let released = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                blocking: false,
                day: date(day: 20)
            )
        )

        let session = try XCTUnwrap(released.workspace.sessions.first)
        XCTAssertNotEqual(session.id, original.id)
        XCTAssertFalse(session.blocking)
        XCTAssertEqual(session.timeRange.start, date(day: 20, hour: 9))
        XCTAssertEqual(session.timeRange.end, date(day: 20, hour: 10))
    }

    func testFixedSessionReductionRequiresExplicitKeepOrTrim() async throws {
        let system = try await makeSystem()
        let workspace = try await system.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let created = try await system.useCase.addTask(
            CreateTaskRequest(
                title: "Sacred quest",
                durationMinutes: 120,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let original = try XCTUnwrap(created.workspace.sessions.first)
        _ = try await system.useCase.moveSession(
            MoveSessionRequest(
                sessionID: original.id,
                newTimeRange: original.timeRange,
                selectedDay: date(day: 20)
            )
        )

        let updated = try await system.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                blocking: true,
                day: date(day: 20)
            )
        )
        guard case let .fixedSessionOverAllocation(
            taskID,
            pendingZoneChange,
            _,
            scheduledMinutes,
            taskMinutes,
            canTrim,
            selectedDay,
            resolutionTimeZone
        ) = updated.nudge else {
            return XCTFail("Expected a fixed-session over-allocation nudge")
        }
        XCTAssertEqual(scheduledMinutes, 120)
        XCTAssertEqual(taskMinutes, 60)
        XCTAssertTrue(canTrim)
        XCTAssertEqual(updated.workspace.sessions.first?.timeRange, original.timeRange)

        let trimmed = try await system.useCase.resolve(
            .trimFixedSessions(
                taskID: taskID,
                pendingZoneChange: pendingZoneChange,
                selectedDay: selectedDay,
                timeZone: resolutionTimeZone
            )
        )
        let session = try XCTUnwrap(trimmed.workspace.sessions.first)
        XCTAssertEqual(session.id, original.id)
        XCTAssertEqual(session.timeRange.start, original.timeRange.start)
        XCTAssertEqual(session.timeRange.end, date(day: 20, hour: 10))
        XCTAssertTrue(session.blocking)
    }

    func testFixedSessionZoneEditAdoptsZoneAndSupportsMoveAndUndo() async throws {
        let moveSystem = try await makeSystem()
        let workspace = try await moveSystem.useCase.loadWorkspace()
        let workZone = try XCTUnwrap(workspace.zones.first { $0.name == "Work" })
        let studyZone = try XCTUnwrap(workspace.zones.first { $0.name == "Study" })
        let created = try await moveSystem.useCase.addTask(
            CreateTaskRequest(
                title: "Move zones",
                durationMinutes: 60,
                zoneID: workZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let task = try XCTUnwrap(created.workspace.tasks.first)
        let original = try XCTUnwrap(created.workspace.sessions.first)
        _ = try await moveSystem.useCase.moveSession(
            MoveSessionRequest(
                sessionID: original.id,
                newTimeRange: original.timeRange,
                selectedDay: date(day: 20)
            )
        )
        let changed = try await moveSystem.useCase.updateTask(
            updateRequest(
                taskID: task.id,
                title: task.title,
                minutes: 60,
                zoneID: studyZone.id,
                isSplittable: false,
                blocking: true,
                day: date(day: 20)
            )
        )
        guard case let .fixedSessionsOutsideTaskZone(
            taskID,
            _,
            zoneID,
            sessionIDs,
            selectedDay,
            resolutionTimeZone
        ) = changed.nudge else {
            return XCTFail("Expected a fixed-session zone nudge")
        }
        let unchanged = try XCTUnwrap(changed.workspace.sessions.first)
        XCTAssertEqual(unchanged.zoneID, studyZone.id)
        XCTAssertEqual(unchanged.timeRange, original.timeRange)

        let moved = try await moveSystem.useCase.resolve(
            .moveFixedSessionsIntoTaskZone(
                taskID: taskID,
                zoneID: zoneID,
                sessionIDs: sessionIDs,
                selectedDay: selectedDay,
                timeZone: resolutionTimeZone
            )
        )
        let movedSession = try XCTUnwrap(moved.workspace.sessions.first)
        XCTAssertEqual(movedSession.timeRange.start, date(day: 20, hour: 18))
        XCTAssertTrue(movedSession.blocking)

        let undoSystem = try await makeSystem()
        let undoWorkspace = try await undoSystem.useCase.loadWorkspace()
        let undoWorkZone = try XCTUnwrap(undoWorkspace.zones.first { $0.name == "Work" })
        let undoStudyZone = try XCTUnwrap(undoWorkspace.zones.first { $0.name == "Study" })
        let undoCreated = try await undoSystem.useCase.addTask(
            CreateTaskRequest(
                title: "Undo zones",
                durationMinutes: 60,
                zoneID: undoWorkZone.id,
                isSplittable: false,
                selectedDay: date(day: 20),
                timeZone: timeZone
            )
        )
        let undoTask = try XCTUnwrap(undoCreated.workspace.tasks.first)
        let undoSession = try XCTUnwrap(undoCreated.workspace.sessions.first)
        _ = try await undoSystem.useCase.moveSession(
            MoveSessionRequest(
                sessionID: undoSession.id,
                newTimeRange: undoSession.timeRange,
                selectedDay: date(day: 20)
            )
        )
        let undoChanged = try await undoSystem.useCase.updateTask(
            updateRequest(
                taskID: undoTask.id,
                title: undoTask.title,
                minutes: 60,
                zoneID: undoStudyZone.id,
                isSplittable: false,
                blocking: true,
                day: date(day: 20)
            )
        )
        guard case let .fixedSessionsOutsideTaskZone(
            undoTaskID,
            undoPreviousZoneID,
            _,
            undoSessionIDs,
            undoDay,
            undoTimeZone
        ) = undoChanged.nudge else {
            return XCTFail("Expected a fixed-session zone nudge")
        }
        let restored = try await undoSystem.useCase.resolve(
            .restoreTaskZone(
                taskID: undoTaskID,
                previousZoneID: undoPreviousZoneID,
                sessionIDs: undoSessionIDs,
                selectedDay: undoDay,
                timeZone: undoTimeZone
            )
        )
        XCTAssertEqual(restored.workspace.tasks.first?.zoneID, undoWorkZone.id)
        XCTAssertEqual(restored.workspace.sessions.first?.zoneID, undoWorkZone.id)
        XCTAssertEqual(restored.workspace.sessions.first?.timeRange, undoSession.timeRange)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    private enum TestResolution {
        case applyCandidate(ResolutionCandidate)
        case separateSessions(firstSessionID: UUID, secondSessionID: UUID)
        case moveSecondSessionAfterFirst(firstSessionID: UUID, secondSessionID: UUID)
        case shiftDependencyChain(goalID: UUID, timeZone: TimeZone)
        case stackMissedAndSuccessor(missedTaskID: UUID, successorTaskID: UUID)
        case makeTaskIndependent(taskID: UUID, dependencyID: UUID)
        case replanSessionsForZone(zoneID: UUID, sessionIDs: [UUID], timeZone: TimeZone)
        case restoreZone(Zone)
        case trimFixedSessions(
            taskID: UUID,
            pendingZoneChange: TaskZoneChange?,
            selectedDay: Date,
            timeZone: TimeZone
        )
        case moveFixedSessionsIntoTaskZone(
            taskID: UUID,
            zoneID: UUID,
            sessionIDs: [UUID],
            selectedDay: Date,
            timeZone: TimeZone
        )
        case restoreTaskZone(
            taskID: UUID,
            previousZoneID: UUID?,
            sessionIDs: [UUID],
            selectedDay: Date,
            timeZone: TimeZone
        )
    }

    private struct TestScheduleActions {
        let selectedDay: Date
        let loadUseCase: any LoadScheduleWorkspaceUseCase
        let createTaskUseCase: any CreateTaskUseCase
        let updateTaskUseCase: any UpdateTaskUseCase
        let deleteTaskUseCase: any DeleteTaskUseCase
        let createGoalUseCase: any CreateSevenTaskGoalUseCase
        let moveSessionUseCase: any MoveSessionUseCase
        let simulateUseCase: any SimulateScheduleScenarioUseCase
        let applyCandidateUseCase: any ApplyScheduleCandidateUseCase
        let separateOverlapUseCase: any SeparateOverlappingSessionsUseCase
        let moveOverlapUseCase: any MoveOverlappingSessionUseCase
        let shiftGoalChainUseCase: any ShiftGoalDependencyChainUseCase
        let stackTasksUseCase: any StackDependentTasksUseCase
        let makeIndependentUseCase: any MakeTaskIndependentUseCase
        let replanZoneUseCase: any ReplanZoneSessionsUseCase
        let restoreZoneUseCase: any RestoreZoneUseCase
        let trimFixedUseCase: any TrimFixedOverAllocationUseCase
        let moveFixedUseCase: any MoveFixedSessionsIntoZoneUseCase
        let restoreTaskZoneUseCase: any RestoreTaskZoneUseCase

        func loadWorkspace() async throws -> ScheduleWorkspace {
            try await loadUseCase.execute(for: selectedDay)
        }

        func addTask(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
            try await createTaskUseCase.execute(request)
        }

        func updateTask(
            _ request: UpdateTaskRequest
        ) async throws -> ScheduleOperationResult {
            try await updateTaskUseCase.execute(request)
        }

        func deleteTask(id: UUID) async throws -> ScheduleWorkspace {
            try await deleteTaskUseCase.execute(taskID: id, selectedDay: selectedDay)
        }

        func createSevenTaskGoal(
            _ request: CreateSevenTaskGoalRequest
        ) async throws -> ScheduleOperationResult {
            try await createGoalUseCase.execute(request)
        }

        func moveSession(_ request: MoveSessionRequest) async throws -> ScheduleWorkspace {
            try await moveSessionUseCase.execute(request)
        }

        func simulate(
            _ scenario: ScheduleSimulationScenario,
            on day: Date,
            in timeZone: TimeZone
        ) async throws -> ScheduleOperationResult {
            try await simulateUseCase.execute(scenario, on: day, in: timeZone)
        }

        func resolve(_ resolution: TestResolution) async throws -> ScheduleOperationResult {
            switch resolution {
            case let .applyCandidate(candidate):
                try await applyCandidateUseCase.execute(candidate, on: selectedDay)
            case let .separateSessions(firstSessionID, secondSessionID):
                try await separateOverlapUseCase.execute(
                    OverlappingSessionsRequest(
                        firstSessionID: firstSessionID,
                        secondSessionID: secondSessionID
                    ),
                    on: selectedDay
                )
            case let .moveSecondSessionAfterFirst(firstSessionID, secondSessionID):
                try await moveOverlapUseCase.execute(
                    OverlappingSessionsRequest(
                        firstSessionID: firstSessionID,
                        secondSessionID: secondSessionID
                    ),
                    on: selectedDay
                )
            case let .shiftDependencyChain(goalID, timeZone):
                try await shiftGoalChainUseCase.execute(
                    ShiftGoalDependencyChainRequest(goalID: goalID, timeZone: timeZone),
                    on: selectedDay
                )
            case let .stackMissedAndSuccessor(missedTaskID, successorTaskID):
                try await stackTasksUseCase.execute(
                    StackDependentTasksRequest(
                        missedTaskID: missedTaskID,
                        successorTaskID: successorTaskID
                    ),
                    on: selectedDay
                )
            case let .makeTaskIndependent(taskID, dependencyID):
                try await makeIndependentUseCase.execute(
                    MakeTaskIndependentRequest(
                        taskID: taskID,
                        dependencyID: dependencyID
                    ),
                    on: selectedDay
                )
            case let .replanSessionsForZone(zoneID, sessionIDs, timeZone):
                try await replanZoneUseCase.execute(
                    ReplanZoneSessionsRequest(
                        zoneID: zoneID,
                        sessionIDs: sessionIDs,
                        timeZone: timeZone
                    ),
                    on: selectedDay
                )
            case let .restoreZone(zone):
                try await restoreZoneUseCase.execute(zone, on: selectedDay)
            case let .trimFixedSessions(
                taskID,
                pendingZoneChange,
                selectedDay,
                timeZone
            ):
                try await trimFixedUseCase.execute(
                    FixedOverAllocationRequest(
                        taskID: taskID,
                        pendingZoneChange: pendingZoneChange,
                        selectedDay: selectedDay,
                        timeZone: timeZone
                    )
                )
            case let .moveFixedSessionsIntoTaskZone(
                taskID,
                zoneID,
                sessionIDs,
                selectedDay,
                timeZone
            ):
                try await moveFixedUseCase.execute(
                    MoveFixedSessionsIntoZoneRequest(
                        taskID: taskID,
                        zoneID: zoneID,
                        sessionIDs: sessionIDs,
                        selectedDay: selectedDay,
                        timeZone: timeZone
                    )
                )
            case let .restoreTaskZone(
                taskID,
                previousZoneID,
                sessionIDs,
                selectedDay,
                timeZone
            ):
                try await restoreTaskZoneUseCase.execute(
                    RestoreTaskZoneRequest(
                        taskID: taskID,
                        previousZoneID: previousZoneID,
                        sessionIDs: sessionIDs,
                        selectedDay: selectedDay,
                        timeZone: timeZone
                    )
                )
            }
        }
    }

    private struct TestSystem {
        let useCase: TestScheduleActions
        let zoneRepository: DefaultZoneRepository
        let taskRepository: LocalTaskRepositoryStub
        let sessionRepository: LocalSessionRepositoryStub
    }

    private func makeSystem() async throws -> TestSystem {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let zoneSource = SwiftDataZoneDataSource(modelContainer: container)
        let templateSource = SwiftDataTemplateDataSource(modelContainer: container)
        let overrideSource = SwiftDataTemplateOverrideDataSource(modelContainer: container)
        let taskSource = SwiftDataTaskDataSource(modelContainer: container)
        let sessionSource = SwiftDataSessionDataSource(modelContainer: container)
        let goalSource = SwiftDataGoalDataSource(modelContainer: container)
        try await templateSource.addTemplate(
            TemplateData(
                id: UUID(),
                name: "Every day",
                weekDays: Set(1...7),
                zones: try defaultZones()
            )
        )
        let zoneRepository = makeZoneRepository(
            zoneDataSource: zoneSource,
            templateDataSource: templateSource,
            templateOverrideDataSource: overrideSource
        )
        let taskRepository = LocalTaskRepositoryStub(
            dataSource: taskSource,
            sessionDataSource: sessionSource
        )
        let sessionRepository = LocalSessionRepositoryStub(dataSource: sessionSource)
        let goalRepository = DefaultGoalRepository(localDataSource: goalSource)
        let resolver = CalendarZoneWindowResolver()
        let workspaceProvider = DefaultScheduleWorkspaceProvider(
            zoneRepository: zoneRepository,
            goalRepository: goalRepository,
            taskRepository: taskRepository,
            sessionRepository: sessionRepository
        )
        let engine = DefaultScheduleEngine()
        let reconciler = DefaultTaskScheduleReconciler(
            workspaceProvider: workspaceProvider,
            sessionRepository: sessionRepository,
            engine: DefaultScheduleEngine(),
            zoneWindowResolver: resolver
        )
        let createGoal = DefaultCreateSevenTaskGoalUseCase(
            workspaceProvider: workspaceProvider,
            goalRepository: goalRepository,
            taskRepository: taskRepository,
            sessionRepository: sessionRepository,
            engine: engine
        )
        let resetSimulation = ResetScheduleSimulationUseCaseImpl(
            workspaceProvider: workspaceProvider,
            taskRepository: taskRepository,
            goalRepository: goalRepository,
            sessionRepository: sessionRepository
        )
        let useCase = TestScheduleActions(
            selectedDay: date(day: 20),
            loadUseCase: DefaultLoadScheduleWorkspaceUseCase(
                workspaceProvider: workspaceProvider
            ),
            createTaskUseCase: DefaultCreateTaskUseCase(
                taskRepository: taskRepository,
                reconciler: reconciler
            ),
            updateTaskUseCase: DefaultUpdateTaskUseCase(
                workspaceProvider: workspaceProvider,
                taskRepository: taskRepository,
                sessionRepository: sessionRepository,
                reconciler: reconciler
            ),
            deleteTaskUseCase: DefaultDeleteTaskUseCase(
                workspaceProvider: workspaceProvider,
                taskRepository: taskRepository,
                sessionRepository: sessionRepository
            ),
            createGoalUseCase: createGoal,
            moveSessionUseCase: DefaultMoveSessionUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository
            ),
            simulateUseCase: SimulateScheduleScenarioUseCaseImpl(
                workspaceProvider: workspaceProvider,
                zoneRepository: zoneRepository,
                taskRepository: taskRepository,
                sessionRepository: sessionRepository,
                engine: engine,
                createGoalUseCase: createGoal,
                resetUseCase: resetSimulation
            ),
            applyCandidateUseCase: DefaultApplyScheduleCandidateUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository
            ),
            separateOverlapUseCase: DefaultSeparateOverlappingSessionsUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository
            ),
            moveOverlapUseCase: DefaultMoveOverlappingSessionUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository
            ),
            shiftGoalChainUseCase: DefaultShiftGoalDependencyChainUseCase(
                workspaceProvider: workspaceProvider,
                taskRepository: taskRepository,
                goalRepository: goalRepository,
                sessionRepository: sessionRepository
            ),
            stackTasksUseCase: DefaultStackDependentTasksUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository
            ),
            makeIndependentUseCase: DefaultMakeTaskIndependentUseCase(
                workspaceProvider: workspaceProvider,
                taskRepository: taskRepository
            ),
            replanZoneUseCase: DefaultReplanZoneSessionsUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository,
                zoneWindowResolver: resolver
            ),
            restoreZoneUseCase: DefaultRestoreZoneUseCase(
                workspaceProvider: workspaceProvider,
                zoneRepository: zoneRepository
            ),
            trimFixedUseCase: DefaultTrimFixedOverAllocationUseCase(
                taskRepository: taskRepository,
                sessionRepository: sessionRepository,
                reconciler: reconciler
            ),
            moveFixedUseCase: DefaultMoveFixedSessionsIntoZoneUseCase(
                workspaceProvider: workspaceProvider,
                sessionRepository: sessionRepository,
                zoneWindowResolver: resolver,
                availabilityCalculator: DefaultAvailabilityCalculator(),
                reconciler: reconciler
            ),
            restoreTaskZoneUseCase: DefaultRestoreTaskZoneUseCase(
                taskRepository: taskRepository,
                sessionRepository: sessionRepository,
                reconciler: reconciler
            )
        )
        return TestSystem(
            useCase: useCase,
            zoneRepository: zoneRepository,
            taskRepository: taskRepository,
            sessionRepository: sessionRepository
        )
    }

    private func defaultZones() throws -> [Zone] {
        [
            try Zone(
                id: UUID(),
                name: "Morning",
                color: ZoneColor(hex: "#F4B942"),
                startTime: LocalTime(hour: 7, minute: 0),
                endTime: LocalTime(hour: 9, minute: 0)
            ),
            try Zone(
                id: UUID(),
                name: "Work",
                color: ZoneColor(hex: "#4A90E2"),
                startTime: LocalTime(hour: 9, minute: 0),
                endTime: LocalTime(hour: 17, minute: 0)
            ),
            try Zone(
                id: UUID(),
                name: "Study",
                color: ZoneColor(hex: "#8E5BD9"),
                startTime: LocalTime(hour: 18, minute: 0),
                endTime: LocalTime(hour: 21, minute: 0)
            ),
            try Zone(
                id: UUID(),
                name: "Personal",
                color: ZoneColor(hex: "#EF6C8F"),
                startTime: LocalTime(hour: 21, minute: 0),
                endTime: LocalTime(hour: 0, minute: 0)
            ),
        ]
    }

    private func updateRequest(
        taskID: UUID,
        title: String,
        minutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        blocking: Bool = false,
        day: Date
    ) -> UpdateTaskRequest {
        UpdateTaskRequest(
            taskID: taskID,
            title: title,
            durationMinutes: minutes,
            zoneID: zoneID,
            isSplittable: isSplittable,
            blocking: blocking,
            selectedDay: day,
            timeZone: timeZone
        )
    }

    private func date(day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        calendar.date(
            from: DateComponents(year: 2026, month: 7, day: day, hour: hour, minute: minute)
        ) ?? .distantPast
    }
}
