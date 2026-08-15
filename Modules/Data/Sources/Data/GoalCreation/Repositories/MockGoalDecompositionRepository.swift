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

        let confirmedGoalID = Self.scheduleGoalID
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
        let assignedZoneID = mockUUID(
            "8ec08d65-7a79-4125-9d14-4ea808083126"
        )

        return GoalScheduleProposal(
            goalID: goalID,
            proposedSessions: [
                GoalScheduleSession(
                    taskID: mockUUID("9a4bf2b8-8647-4103-b142-98b1d9f8697e"),
                    taskTitle: "Verify gym access and operating hours",
                    zoneID: assignedZoneID,
                    start: scheduleDate(hour: 10, minute: 35),
                    end: scheduleDate(hour: 10, minute: 50)
                ),
                GoalScheduleSession(
                    taskID: mockUUID("b135dcc2-54fa-491f-aef9-048f48a16290"),
                    taskTitle: "Confirm workplace policy for exercise during work hours",
                    zoneID: assignedZoneID,
                    start: scheduleDate(hour: 11),
                    end: scheduleDate(hour: 11, minute: 15)
                ),
                GoalScheduleSession(
                    taskID: mockUUID("c9901b41-8544-4dfd-8bf1-1f939b1beb57"),
                    taskTitle: "Block workout slots in your calendar",
                    zoneID: assignedZoneID,
                    start: scheduleDate(hour: 11, minute: 55),
                    end: scheduleDate(hour: 12, minute: 10)
                )
            ],
            manualSessions: [],
            suggestions: [
                noZoneSuggestion(
                    taskID: "f21767e4-cc95-46dd-9d3b-2e49ff16a933",
                    title: "Write a weekly cardio plan",
                    startHour: 11,
                    startMinute: 25,
                    endHour: 11,
                    endMinute: 45
                ),
                noZoneSuggestion(
                    taskID: "ecfb0885-dbe4-4071-98e0-5adaa48ab99c",
                    title: "Pack a gym bag for the first session",
                    startHour: 12,
                    startMinute: 20,
                    endHour: 12,
                    endMinute: 40
                ),
                noZoneSuggestion(
                    taskID: "dd2e92ad-8be4-42df-88ab-7fd91cc96ec7",
                    title: "Complete first cardio session",
                    startHour: 12,
                    startMinute: 50,
                    endHour: 13,
                    endMinute: 30
                ),
                noZoneSuggestion(
                    taskID: "473e4c3a-e62c-4ef8-847f-ef6ad32a5949",
                    title: "Complete second cardio session",
                    startHour: 13,
                    startMinute: 40,
                    endHour: 14,
                    endMinute: 20
                ),
                noZoneSuggestion(
                    taskID: "0247a642-6b6a-4a02-a4d7-2d5ad2a1ed06",
                    title: "Complete third cardio session",
                    startHour: 14,
                    startMinute: 30,
                    endHour: 15,
                    endMinute: 10
                ),
                noZoneSuggestion(
                    taskID: "8fe9fd79-6c8e-4d07-82eb-486ea93e8907",
                    title: "Complete fourth cardio session",
                    startHour: 15,
                    startMinute: 20,
                    endHour: 16,
                    endMinute: 0
                ),
                noZoneSuggestion(
                    taskID: "7dc93300-16ff-4683-8b48-a0375b03e1ed",
                    title: "Review first week and adjust plan",
                    startHour: 16,
                    startMinute: 10,
                    endHour: 16,
                    endMinute: 30
                )
            ],
            unscheduledTasks: []
        )
    }

    private static func noZoneSuggestion(
        taskID: String,
        title: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int
    ) -> GoalScheduleSuggestion {
        GoalScheduleSuggestion(
            session: GoalScheduleSession(
                taskID: mockUUID(taskID),
                taskTitle: title,
                zoneID: nil,
                start: scheduleDate(hour: startHour, minute: startMinute),
                end: scheduleDate(hour: endHour, minute: endMinute)
            ),
            type: .noZone,
            reason: "No Health-matched zone available; scheduled in available free time.",
            overlap: nil
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

    private static let scheduleGoalID = mockUUID(
        "1dc4dcac-6c18-4654-973c-21943b4851fe"
    )

    private static func mockUUID(_ value: String) -> UUID {
        guard let id = UUID(uuidString: value) else {
            preconditionFailure("Invalid UUID in mock goal schedule fixture")
        }
        return id
    }

    private static func scheduleDate(
        hour: Int,
        minute: Int = 0,
        second: Int = 55
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        guard let date = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 8,
                day: 14,
                hour: hour,
                minute: minute,
                second: second
            )
        ) else {
            preconditionFailure("Invalid date in mock goal schedule fixture")
        }
        return date
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
