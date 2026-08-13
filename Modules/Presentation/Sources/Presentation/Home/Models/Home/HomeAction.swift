import Foundation

enum HomeAction {
    case appeared
    case refresh
    case selectDay(Date)
    case presentSession(UUID)
    case dismissSession
    case moveSession(sessionID: UUID, verticalPoints: CGFloat, hourHeight: CGFloat)
    case rescheduleSession(sessionID: UUID, start: Date)
    case setSessionCompletion(sessionID: UUID, isCompleted: Bool)
    case dismissError
    case dismissCompletionReward
    case dismissCompletionRewardAnimation
}
