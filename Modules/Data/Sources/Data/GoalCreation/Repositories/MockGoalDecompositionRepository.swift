import Domain
import Foundation

public actor MockGoalDecompositionRepository: GoalDecompositionRepository {
    private var sessionID: UUID?
    private var goalID: UUID?
    private var hasProposal = false
    private var isConfirmed = false

    public init() {}

    public func sendMessage(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse {
        try await Task.sleep(for: .milliseconds(900))

        if request.sessionID == nil {
            let newSessionID = UUID()
            sessionID = newSessionID
            goalID = nil
            hasProposal = false
            isConfirmed = false
            return GoalDecompositionResponse(
                sessionID: newSessionID,
                blocks: [
                    .text("I’ll turn that into a plan you can actually finish."),
                    .question(
                        GoalDecompositionQuestion(
                            text: "How much time would you like to give yourself?",
                            options: ["2–4 weeks", "1–2 months", "3–6 months"]
                        )
                    )
                ],
                hasProposal: false
            )
        }

        guard let activeSessionID = sessionID,
              request.sessionID == activeSessionID else {
            throw MockGoalDecompositionError.invalidSession
        }
        guard !isConfirmed else {
            throw MockGoalDecompositionError.alreadyConfirmed
        }

        hasProposal = true
        return GoalDecompositionResponse(
            sessionID: activeSessionID,
            blocks: [
                .text(
                    "Here’s a focused plan. I split the larger work into sessions so it stays manageable."
                ),
                .proposal(Self.portfolioProposal)
            ],
            hasProposal: true
        )
    }

    public func confirmProposal(sessionID: UUID) async throws -> ConfirmedGoal {
        try await Task.sleep(for: .milliseconds(650))
        guard sessionID == self.sessionID else {
            throw MockGoalDecompositionError.invalidSession
        }
        guard hasProposal else {
            throw MockGoalDecompositionError.noProposal
        }

        let confirmedGoalID = UUID()
        goalID = confirmedGoalID
        isConfirmed = true
        return ConfirmedGoal(
            id: confirmedGoalID,
            title: Self.portfolioProposal.title,
            tasks: Self.confirmedTasks
        )
    }

    public func requestScheduleProposal(
        goalID: UUID
    ) async throws -> GoalScheduleProposal {
        try await Task.sleep(for: .milliseconds(650))
        guard isConfirmed, goalID == self.goalID else {
            throw MockGoalDecompositionError.goalNotConfirmed
        }
        return Self.scheduleProposal(goalID: goalID)
    }

    private static func scheduleProposal(goalID: UUID) -> GoalScheduleProposal {
        let assignedZoneID = UUID()
        let proposedSession = GoalScheduleSession(
            taskID: taskIDs[0],
            taskTitle: confirmedTasks[0].title,
            zoneID: assignedZoneID,
            start: date(dayOffset: 1, hour: 9),
            end: date(dayOffset: 1, hour: 9, minute: 45)
        )
        let manualSession = GoalScheduleSession(
            taskID: taskIDs[1],
            taskTitle: confirmedTasks[1].title,
            zoneID: nil,
            start: date(dayOffset: 1, hour: 10),
            end: date(dayOffset: 1, hour: 10, minute: 40)
        )
        let noZoneSession = GoalScheduleSession(
            taskID: taskIDs[2],
            taskTitle: confirmedTasks[2].title,
            zoneID: nil,
            start: date(dayOffset: 1, hour: 11),
            end: date(dayOffset: 1, hour: 12)
        )
        let overlapSession = GoalScheduleSession(
            taskID: taskIDs[3],
            taskTitle: confirmedTasks[3].title,
            zoneID: assignedZoneID,
            start: date(dayOffset: 1, hour: 13),
            end: date(dayOffset: 1, hour: 14)
        )

        return GoalScheduleProposal(
            goalID: goalID,
            proposedSessions: [proposedSession],
            manualSessions: [manualSession],
            suggestions: [
                GoalScheduleSuggestion(
                    session: noZoneSession,
                    type: .noZone,
                    reason: "No matching zone is available for this task. The suggested time uses unzoned free time instead.",
                    overlap: nil
                ),
                GoalScheduleSuggestion(
                    session: overlapSession,
                    type: .overlap,
                    reason: "This suggested session overlaps another task. Accept it only if you want both sessions at this time.",
                    overlap: GoalScheduleOverlapInfo(
                        taskTitle: "Team stand-up",
                        start: date(dayOffset: 1, hour: 13, minute: 15),
                        end: date(dayOffset: 1, hour: 13, minute: 45),
                        mandatory: true,
                        points: 5
                    )
                )
            ],
            unscheduledTasks: [
                GoalScheduleUnscheduledTask(
                    taskID: taskIDs[4],
                    taskTitle: confirmedTasks[4].title,
                    message: "No suitable time was found. Add a session manually or continue without this task."
                )
            ]
        )
    }

    public func confirmSchedule(
        goalID: UUID,
        sessions: [GoalScheduleConfirmationItem]
    ) async throws -> [ConfirmedGoalScheduleSession] {
        guard isConfirmed, goalID == self.goalID else {
            throw MockGoalDecompositionError.goalNotConfirmed
        }
        return sessions.map {
            ConfirmedGoalScheduleSession(
                id: UUID(),
                taskID: $0.taskID,
                zoneID: $0.zoneID,
                start: $0.start,
                end: $0.end
            )
        }
    }

    private static let portfolioProposal = GoalProposal(
        title: "Build a personal portfolio website",
        description: "Create and launch a polished portfolio that showcases your best work.",
        targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
        tasks: [
            GoalTaskProposal(
                id: "t1",
                title: "Define the portfolio story",
                description: "Choose the audience, key message, and strongest projects.",
                estimatedDuration: 45,
                estimatedPoints: 8,
                mandatory: true,
                allowsTaskSplitting: false,
                dependencyIDs: [],
                category: nil
            ),
            GoalTaskProposal(
                id: "t2",
                title: "Design the core pages",
                description: "Create the visual direction and responsive page layouts.",
                estimatedDuration: 120,
                estimatedPoints: 20,
                mandatory: true,
                allowsTaskSplitting: true,
                dependencyIDs: ["t1"],
                category: nil
            ),
            GoalTaskProposal(
                id: "t3",
                title: "Build and populate the site",
                description: "Implement the pages and add project case studies.",
                estimatedDuration: 180,
                estimatedPoints: 30,
                mandatory: true,
                allowsTaskSplitting: true,
                dependencyIDs: ["t2"],
                category: nil
            ),
            GoalTaskProposal(
                id: "t4",
                title: "Review and launch",
                description: "Test the experience, connect the domain, and publish.",
                estimatedDuration: 60,
                estimatedPoints: 12,
                mandatory: true,
                allowsTaskSplitting: false,
                dependencyIDs: ["t3"],
                category: nil
            ),
            GoalTaskProposal(
                id: "t5",
                title: "Prepare the launch announcement",
                description: "Write a short announcement and prepare the final launch checklist.",
                estimatedDuration: 30,
                estimatedPoints: 6,
                mandatory: false,
                allowsTaskSplitting: false,
                dependencyIDs: ["t4"],
                category: nil
            )
        ]
    )

    private static let taskIDs = (0..<5).map { _ in UUID() }

    private static let confirmedTasks = [
        ConfirmedGoalTask(
            id: taskIDs[0],
            title: "Define the portfolio story",
            estimatedDuration: 45
        ),
        ConfirmedGoalTask(
            id: taskIDs[1],
            title: "Design the core pages",
            estimatedDuration: 40
        ),
        ConfirmedGoalTask(
            id: taskIDs[2],
            title: "Build and populate the site",
            estimatedDuration: 60
        ),
        ConfirmedGoalTask(
            id: taskIDs[3],
            title: "Review and launch",
            estimatedDuration: 60
        ),
        ConfirmedGoalTask(
            id: taskIDs[4],
            title: "Prepare the launch announcement",
            estimatedDuration: 30
        )
    ]

    private static func date(
        dayOffset: Int,
        hour: Int,
        minute: Int = 0
    ) -> Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let day = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: startOfToday
        ) ?? startOfToday
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: day
        ) ?? day
    }
}

public enum MockGoalDecompositionError: LocalizedError, Sendable {
    case invalidSession
    case alreadyConfirmed
    case noProposal
    case goalNotConfirmed

    public var errorDescription: String? {
        switch self {
        case .invalidSession:
            "This planning session could not be found."
        case .alreadyConfirmed:
            "This goal has already been confirmed."
        case .noProposal:
            "A proposal is needed before confirming."
        case .goalNotConfirmed:
            "Confirm the goal before scheduling it."
        }
    }
}
