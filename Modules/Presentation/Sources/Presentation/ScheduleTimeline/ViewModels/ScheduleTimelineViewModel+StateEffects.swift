import Domain
import Foundation

extension ScheduleTimelineViewModel {
    func runOperation(
        _ operation: @escaping @MainActor () async throws -> ScheduleOperationResult
    ) {
        Task {
            await perform {
                apply(try await operation())
            }
        }
    }

    func runWorkspaceOperation(
        _ operation: @escaping @MainActor () async throws -> ScheduleWorkspace
    ) {
        Task {
            await perform {
                apply(workspace: try await operation())
            }
        }
    }

    func perform(_ operation: () async throws -> Void) async {
        reduce {
            $0.status = .loading
            $0.errorMessage = nil
        }
        defer { reduce { $0.status = .ready } }
        do {
            try await operation()
        } catch is CancellationError {
            return
        } catch {
            reduce { $0.errorMessage = error.localizedDescription }
        }
    }

    func apply(_ result: ScheduleOperationResult) {
        apply(workspace: result.workspace)
        reduce { $0.activeNudge = result.nudge.map(mapper.present) }
    }

    func apply(workspace: ScheduleWorkspace) {
        let content = mapper.mapContent(
            workspace: workspace,
            selectedDay: state.selectedDay,
            today: Date()
        )
        reduce {
            $0.selectedDayTitle = content.selectedDayTitle
            $0.scheduledMinutes = content.scheduledMinutes
            $0.activeGoalProgress = content.activeGoalProgress
            $0.weekDays = content.weekDays
            $0.zones = content.zones
            $0.zoneOptions = content.zoneOptions
            $0.taskEditorsByID = content.taskEditorsByID
            $0.timelineItems = content.timelineItems
        }
    }
}
