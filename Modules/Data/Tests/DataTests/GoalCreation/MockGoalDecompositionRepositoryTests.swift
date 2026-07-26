import Data
import Domain
import XCTest

final class MockGoalDecompositionRepositoryTests: XCTestCase {
    func testConversationUsesReturnedSessionForFollowUpAndSchedulesConfirmedGoal()
        async throws {
        let repository = MockGoalDecompositionRepository()

        let question = try await repository.sendMessage(
            GoalDecompositionRequest(
                sessionID: nil,
                message: "Build a portfolio"
            )
        )

        XCTAssertFalse(question.hasProposal)
        XCTAssertTrue(
            question.blocks.contains {
                if case .question = $0 { return true }
                return false
            }
        )

        let proposal = try await repository.sendMessage(
            GoalDecompositionRequest(
                sessionID: question.sessionID,
                message: "1–2 months"
            )
        )

        XCTAssertTrue(proposal.hasProposal)
        XCTAssertEqual(proposal.sessionID, question.sessionID)
        XCTAssertTrue(
            proposal.blocks.contains {
                if case .proposal = $0 { return true }
                return false
            }
        )

        let goal = try await repository.confirmProposal(
            sessionID: question.sessionID
        )
        try await repository.scheduleGoal(goalID: goal.id)
    }

    func testFollowUpRejectsUnknownSession() async {
        let repository = MockGoalDecompositionRepository()

        do {
            _ = try await repository.sendMessage(
                GoalDecompositionRequest(
                    sessionID: UUID(),
                    message: "A follow-up"
                )
            )
            XCTFail("Expected an invalid-session error")
        } catch let error as MockGoalDecompositionError {
            guard case .invalidSession = error else {
                return XCTFail("Unexpected mock error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
