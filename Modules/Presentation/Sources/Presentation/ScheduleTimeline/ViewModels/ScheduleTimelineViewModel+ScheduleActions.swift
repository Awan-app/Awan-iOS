import Domain
import Foundation

extension ScheduleTimelineViewModel {
    func loadWorkspace() {
        runWorkspaceOperation {
            try await self.useCases.workspace.execute(for: self.state.selectedDay)
        }
    }

    func createTask(_ submission: ScheduleTaskSubmission) {
        let request = CreateTaskRequest(
            title: submission.title,
            durationMinutes: submission.durationMinutes,
            zoneID: submission.zoneID,
            isSplittable: submission.isSplittable,
            selectedDay: state.selectedDay,
            timeZone: timeZone
        )
        runOperation {
            try await self.useCases.tasks.create.execute(request)
        }
    }

    func updateTask(
        taskID: UUID,
        submission: ScheduleTaskSubmission
    ) {
        let request = UpdateTaskRequest(
            taskID: taskID,
            title: submission.title,
            durationMinutes: submission.durationMinutes,
            zoneID: submission.zoneID,
            isSplittable: submission.isSplittable,
            blocking: submission.blocking,
            selectedDay: state.selectedDay,
            timeZone: timeZone
        )
        runOperation {
            try await self.useCases.tasks.update.execute(request)
        }
    }

    func deleteTask(_ taskID: UUID) {
        runWorkspaceOperation {
            try await self.useCases.tasks.delete.execute(
                taskID: taskID,
                selectedDay: self.state.selectedDay
            )
        }
    }

    func createGoal(_ submission: ScheduleGoalSubmission) {
        let request = CreateSevenTaskGoalRequest(
            name: submission.name,
            zoneID: submission.zoneID,
            taskDurationMinutes: submission.taskDurationMinutes,
            startDay: state.selectedDay,
            timeZone: timeZone
        )
        runOperation {
            try await self.useCases.goals.createSevenTaskGoal.execute(request)
        }
    }

    func moveSession(
        sessionID: UUID,
        verticalPoints: CGFloat,
        hourHeight: CGFloat
    ) {
        guard let session = state.timelineItems.first(where: { $0.id == sessionID }) else {
            return
        }
        let rawMinutes = (verticalPoints / hourHeight) * 60
        let snappedMinutes = (rawMinutes / 15).rounded() * 15
        guard snappedMinutes != 0,
              let start = calendar.date(
                byAdding: .minute,
                value: Int(snappedMinutes),
                to: session.start
              ),
              let end = calendar.date(
                byAdding: .minute,
                value: Int(snappedMinutes),
                to: session.end
              ),
              let range = try? TimeRange(start: start, end: end) else {
            return
        }
        runWorkspaceOperation {
            try await self.useCases.sessions.move.execute(
                MoveSessionRequest(
                    sessionID: sessionID,
                    newTimeRange: range,
                    selectedDay: self.state.selectedDay
                )
            )
        }
    }
}
