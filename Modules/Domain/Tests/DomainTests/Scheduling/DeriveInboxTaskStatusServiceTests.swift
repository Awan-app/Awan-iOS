import Combine
import Foundation
import XCTest
@testable import Domain

// MARK: - DeriveInboxTaskStatusServiceTests

final class DeriveInboxTaskStatusServiceTests: XCTestCase {
    private let service = DeriveInboxTaskStatusService()

    // MARK: - Drafted

    func testNoSessions_returnsDrafted() {
        let result = service.derive(from: [], completedAt: nil)
        XCTAssertEqual(result, .drafted)
    }

    // MARK: - Cancelled

    func testAllSessionsCancelled_returnsCancelled() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .cancelled),
            makeSession(taskID: taskID, status: .cancelled)
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .cancelled)
    }

    // MARK: - Completed sessions do not complete the task

    func testAllNonCancelledCompleted_returnsActiveWithoutTaskCompletion() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .completed),
            makeSession(taskID: taskID, status: .completed),
            makeSession(taskID: taskID, status: .cancelled) // Cancelled is excluded from the "all non-cancelled" check
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testSingleCompletedSession_returnsActiveWithoutTaskCompletion() throws {
        let taskID = UUID()
        let sessions = [makeSession(taskID: taskID, status: .completed)]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testCompletedAndCancelledMix_returnsActiveWithoutTaskCompletion() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .completed),
            makeSession(taskID: taskID, status: .cancelled)
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    // MARK: - Active

    func testMixedPlannedAndCompleted_returnsActive() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .planned),
            makeSession(taskID: taskID, status: .completed)
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testAllPlanned_returnsActive() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .planned),
            makeSession(taskID: taskID, status: .planned)
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testSinglePlannedSession_returnsActive() throws {
        let taskID = UUID()
        let sessions = [makeSession(taskID: taskID, status: .planned)]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testMissedSession_returnsActive() throws {
        let taskID = UUID()
        let sessions = [makeSession(taskID: taskID, status: .missed)]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testMixedPlannedAndCancelled_returnsActive() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .planned),
            makeSession(taskID: taskID, status: .cancelled)
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    func testCompletedPlannedCancelled_returnsActive() throws {
        let taskID = UUID()
        let sessions = [
            makeSession(taskID: taskID, status: .completed),
            makeSession(taskID: taskID, status: .planned),
            makeSession(taskID: taskID, status: .cancelled)
        ]
        let result = service.derive(from: sessions, completedAt: nil)
        XCTAssertEqual(result, .active)
    }

    // MARK: - Helpers

    private func makeSession(taskID: UUID, status: Session.Status) -> Session {
        Session(
            id: UUID(),
            taskID: taskID,
            zoneID: nil,
            timeRange: (try? TimeRange(start: Date(), end: Date().addingTimeInterval(3600))) ?? TimeRange.distantFuture,
            blocking: false,
            status: status
        )
    }
}

// MARK: - TimeRange convenience

private extension TimeRange {
    static var distantFuture: TimeRange {
        // Force-unwrap only in test code for a documented invariant
        try! TimeRange(start: .distantFuture, end: .distantFuture.addingTimeInterval(3600))
    }
}
