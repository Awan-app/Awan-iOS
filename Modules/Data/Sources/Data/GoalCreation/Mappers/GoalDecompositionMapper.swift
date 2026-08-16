import Domain
import Foundation

extension GoalDecompositionResponseDTO {
    func toDomain() throws -> GoalDecompositionResponse {
        GoalDecompositionResponse(
            sessionID: sessionID,
            blocks: try blocks.map { try $0.toDomain() },
            hasProposal: hasProposal
        )
    }
}

private extension GoalDecompositionBlockDTO {
    func toDomain() throws -> GoalDecompositionBlock {
        switch self {
        case .text(let block):
            .text(block.text)
        case .question(let block):
            .question(
                GoalDecompositionQuestion(
                    text: block.text,
                    options: block.options
                )
            )
        case .proposal(let block):
            .proposal(try block.proposal.toDomain())
        }
    }
}

private extension GoalProposalDTO {
    func toDomain() throws -> GoalProposal {
        GoalProposal(
            title: title,
            description: description,
            targetDate: try targetDate.map(GoalDecompositionDateParser.date),
            tasks: tasks.map { $0.toDomain() }
        )
    }
}

private extension GoalTaskProposalDTO {
    func toDomain() -> GoalTaskProposal {
        GoalTaskProposal(
            id: tempID,
            title: title,
            description: description,
            estimatedDuration: estimatedDuration,
            estimatedPoints: estimatedPoints,
            mandatory: mandatory,
            allowsTaskSplitting: allowsTaskSplitting,
            dependencyIDs: dependencyIDs,
            category: category.map {
                GoalProposalCategory(id: $0.id, name: $0.name)
            }
        )
    }
}

enum GoalDecompositionMappingError: LocalizedError {
    case invalidDate(String)
    case invalidSuggestionType(String)

    var errorDescription: String? {
        switch self {
        case .invalidDate(let value):
            "The goal response contained an invalid date: \(value)"
        case .invalidSuggestionType(let value):
            "The schedule response contained an invalid suggestion type: \(value)"
        }
    }
}

extension GoalScheduleProposalResponseDTO {
    func toDomain(timeZoneID: String) throws -> GoalScheduleProposal {
        GoalScheduleProposal(
            goalID: goalID,
            proposedSessions: try proposedSessions.map {
                try $0.toDomain(timeZoneID: timeZoneID)
            },
            suggestions: try suggestions.map {
                try $0.toDomain(timeZoneID: timeZoneID)
            },
            unscheduledTasks: unscheduledTasks.map {
                GoalScheduleUnscheduledTask(
                    taskID: $0.taskID,
                    taskTitle: $0.taskTitle,
                    message: $0.message
                )
            }
        )
    }
}

private extension GoalScheduleSessionResponseDTO {
    func toDomain(timeZoneID: String) throws -> GoalScheduleSession {
        GoalScheduleSession(
            taskID: taskID,
            taskTitle: taskTitle,
            zoneID: zoneID,
            start: try GoalScheduleDateMapper.date(start, timeZoneID: timeZoneID),
            end: try GoalScheduleDateMapper.date(end, timeZoneID: timeZoneID)
        )
    }
}

private extension GoalScheduleSuggestionResponseDTO {
    func toDomain(timeZoneID: String) throws -> GoalScheduleSuggestion {
        let type: GoalScheduleSuggestionType = switch suggestionType {
        case "NO_ZONE": .noZone
        case "OVERLAP": .overlap
        default: throw GoalDecompositionMappingError.invalidSuggestionType(
            suggestionType
        )
        }
        return GoalScheduleSuggestion(
            session: GoalScheduleSession(
                taskID: taskID,
                taskTitle: taskTitle,
                zoneID: zoneID,
                start: try GoalScheduleDateMapper.date(start, timeZoneID: timeZoneID),
                end: try GoalScheduleDateMapper.date(end, timeZoneID: timeZoneID)
            ),
            type: type,
            reason: reason,
            overlap: try overlapInfo.map {
                GoalScheduleOverlapInfo(
                    taskTitle: $0.taskTitle,
                    start: try GoalScheduleDateMapper.date(
                        $0.start,
                        timeZoneID: timeZoneID
                    ),
                    end: try GoalScheduleDateMapper.date(
                        $0.end,
                        timeZoneID: timeZoneID
                    ),
                    mandatory: $0.mandatory,
                    points: $0.points
                )
            }
        )
    }
}

extension ConfirmedGoalScheduleSessionResponseDTO {
    func toDomain(timeZoneID: String) throws -> ConfirmedGoalScheduleSession {
        ConfirmedGoalScheduleSession(
            id: id,
            taskID: taskID,
            zoneID: zoneID,
            start: try GoalScheduleDateMapper.date(start, timeZoneID: timeZoneID),
            end: try GoalScheduleDateMapper.date(end, timeZoneID: timeZoneID)
        )
    }
}

extension ConfirmedGoalResponseDTO {
    func toGoal(createdAt: Date = Date()) throws -> Goal {
        let deadline: Date?
        if let targetDate,
           !targetDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            deadline = try GoalDecompositionDateParser.date(targetDate)
        } else {
            deadline = nil
        }

        return Goal(
            id: id,
            name: title,
            description: description,
            status: try HomeRemoteMapper.goalStatus(status),
            deadline: deadline,
            createdAt: createdAt
        )
    }
}

extension ConfirmedGoalTaskResponseDTO {
    func toTask() throws -> AwanTask {
        return try AwanTask(
            id: id,
            title: title,
            description: description,
            status: HomeRemoteMapper.taskStatus(status, completedAt: nil),
            goalID: goalID,
            duration: TaskDuration(minutes: max(estimatedDuration, 1)),
            isSplittable: allowsTaskSplitting,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            dependencyIDs: Set(dependencyIDs),
            category: category.map {
                TaskCategory(id: $0.id, name: $0.name)
            }
        )
    }
}

enum GoalScheduleDateMapper {
    static func date(_ value: String, timeZoneID: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = formatter.date(from: value) else {
            throw GoalDecompositionMappingError.invalidDate(value)
        }
        return date
    }

    static func string(from date: Date, timeZoneID: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: date)
    }
}

enum GoalDecompositionDateParser {
    static func date(_ value: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: value) else {
            throw GoalDecompositionMappingError.invalidDate(value)
        }
        return date
    }


}
