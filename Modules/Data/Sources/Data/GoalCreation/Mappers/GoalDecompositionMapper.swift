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

    var errorDescription: String? {
        switch self {
        case .invalidDate(let value):
            "The goal response contained an invalid date: \(value)"
        }
    }
}

private enum GoalDecompositionDateParser {
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
