import Domain
import Foundation

public struct SchedulingMockData: Sendable {
    public let tasks: [AwanTask]
    public let goals: [Goal]
    public let sessions: [Session]
    public let templates: [TemplateData]
    public let templateOverrides: [TemplateOverrideData]

    public init(
        tasks: [AwanTask] = [],
        goals: [Goal] = [],
        sessions: [Session] = [],
        templates: [TemplateData] = [],
        templateOverrides: [TemplateOverrideData] = []
    ) {
        self.tasks = tasks
        self.goals = goals
        self.sessions = sessions
        self.templates = templates
        self.templateOverrides = templateOverrides
    }

    public static var preview: SchedulingMockData {
        do {
            return try makePreview()
        } catch {
            preconditionFailure("Invalid scheduling preview data: \(error)")
        }
    }

    private static func makePreview() throws -> SchedulingMockData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let goalID = UUID()
        let planningTaskID = UUID()
        let implementationTaskID = UUID()

        let morningZone = try Zone(
            id: UUID(),
            name: "Morning Focus",
            color: ZoneColor(hex: "6C63FF"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 10, minute: 0)
        )
        let dayZone = try Zone(
            id: UUID(),
            name: "Day Work",
            color: ZoneColor(hex: "2BAE9B"),
            startTime: LocalTime(hour: 10, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
        let eveningZone = try Zone(
            id: UUID(),
            name: "Evening",
            color: ZoneColor(hex: "F39C5A"),
            startTime: LocalTime(hour: 17, minute: 0),
            endTime: LocalTime(hour: 21, minute: 0)
        )
        let nightZone = try Zone(
            id: UUID(),
            name: "Night",
            color: ZoneColor(hex: "D45D79"),
            startTime: LocalTime(hour: 21, minute: 0),
            endTime: LocalTime(hour: 0, minute: 0)
        )

        let overrideMorningZone = try Zone(
            id: UUID(),
            name: "Special Morning",
            color: ZoneColor(hex: "5B8FF9"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 10, minute: 0)
        )
        let overrideDayZone = try Zone(
            id: UUID(),
            name: "Special Day Work",
            color: ZoneColor(hex: "5AD8A6"),
            startTime: LocalTime(hour: 10, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
        let overrideEveningZone = try Zone(
            id: UUID(),
            name: "Special Evening",
            color: ZoneColor(hex: "F6BD16"),
            startTime: LocalTime(hour: 17, minute: 0),
            endTime: LocalTime(hour: 21, minute: 0)
        )
        let overrideNightZone = try Zone(
            id: UUID(),
            name: "Special Night",
            color: ZoneColor(hex: "E8684A"),
            startTime: LocalTime(hour: 21, minute: 0),
            endTime: LocalTime(hour: 0, minute: 0)
        )

        let currentZone = morningZone
        let sessionStart = calendar.date(byAdding: .hour, value: 9, to: today) ?? today
        let sessionEnd = calendar.date(byAdding: .minute, value: 50, to: sessionStart) ?? today
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        let goal = Goal(
            id: goalID,
            name: "Ship scheduling prototype",
            description: "Mock goal supplied by the in-memory Data implementation.",
            status: .active,
            deadline: calendar.date(byAdding: .day, value: 14, to: today) ?? today,
            createdAt: today
        )
        let planningTask = try AwanTask(
            id: planningTaskID,
            title: "Plan the scheduling flow",
            description: "Review the engine inputs and expected output.",
            status: .completed,
            goalID: goalID,
            zoneID: currentZone.id,
            duration: TaskDuration(minutes: 30),
            isSplittable: false,
            mandatory: true,
            estimatedPoints: 3
        )
        let implementationTask = try AwanTask(
            id: implementationTaskID,
            title: "Build the scheduling prototype",
            description: "This task depends on the planning task.",
            status: .inProgress,
            goalID: goalID,
            zoneID: currentZone.id,
            duration: TaskDuration(minutes: 90),
            isSplittable: true,
            mandatory: true,
            estimatedPoints: 8,
            dependencyIDs: [planningTaskID]
        )
        let session = try Session(
            id: UUID(),
            taskID: implementationTaskID,
            zoneID: currentZone.id,
            timeRange: TimeRange(start: sessionStart, end: sessionEnd),
            blocking: false,
            status: .planned
        )

        return SchedulingMockData(
            tasks: [planningTask, implementationTask],
            goals: [goal],
            sessions: [session],
            templates: [
                TemplateData(
                    id: UUID(),
                    name: "Every Day",
                    createdAt: today,
                    weekDays: [1, 2, 3, 4, 5, 6, 7],
                    zones: [morningZone, dayZone, eveningZone, nightZone]
                ),
            ],
            templateOverrides: [
                TemplateOverrideData(
                    id: UUID(),
                    name: "Tomorrow Override",
                    createdAt: today,
                    dateOfDay: tomorrow,
                    zones: [
                        overrideMorningZone,
                        overrideDayZone,
                        overrideEveningZone,
                        overrideNightZone,
                    ]
                ),
            ]
        )
    }
}
