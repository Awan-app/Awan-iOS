import Foundation
import Observation

@Observable
@MainActor
public final class ScheduleTimelineViewModel {
    public private(set) var state: ScheduleTimelineState

    @ObservationIgnored let useCases: ScheduleTimelineUseCases
    @ObservationIgnored let timeZone: TimeZone
    @ObservationIgnored let mapper: ScheduleTimelineStateMapper
    @ObservationIgnored let calendar: Calendar

    public init(
        useCases: ScheduleTimelineUseCases,
        selectedDay: Date = Date(),
        timeZone: TimeZone = .current
    ) {
        self.useCases = useCases
        self.timeZone = timeZone
        self.mapper = ScheduleTimelineStateMapper(timeZone: timeZone)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
        self.state = .initial(selectedDay: selectedDay)
    }

    public func send(_ action: ScheduleTimelineAction) {
        switch action {
        case .appeared:
            loadWorkspace()
        case let .selectDay(day):
            state.selectedDay = day
            loadWorkspace()
        case .presentCreateTask:
            state.presentedSheet = .createTask
        case .presentCreateGoal:
            state.presentedSheet = .createGoal
        case let .presentEditTask(taskID):
            guard state.taskEditorsByID[taskID] != nil else { return }
            state.presentedSheet = .editTask(taskID)
        case .dismissSheet:
            state.presentedSheet = nil
        case let .createTask(submission):
            state.presentedSheet = nil
            createTask(submission)
        case let .updateTask(taskID, submission):
            state.presentedSheet = nil
            updateTask(taskID: taskID, submission: submission)
        case let .deleteTask(taskID):
            state.presentedSheet = nil
            deleteTask(taskID)
        case let .createGoal(submission):
            state.presentedSheet = nil
            createGoal(submission)
        case let .moveSession(sessionID, verticalPoints, hourHeight):
            moveSession(
                sessionID: sessionID,
                verticalPoints: verticalPoints,
                hourHeight: hourHeight
            )
        case let .performNudgeAction(actionID):
            performNudgeAction(actionID)
        case let .simulate(scenario):
            simulate(scenario)
        case .resetSimulation:
            resetSimulation()
        case .dismissError:
            state.errorMessage = nil
        }
    }

    func reduce(_ mutation: (inout ScheduleTimelineState) -> Void) {
        mutation(&state)
    }
}
