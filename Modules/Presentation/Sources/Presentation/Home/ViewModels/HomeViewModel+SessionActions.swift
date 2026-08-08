import Domain
import Foundation

extension HomeViewModel {
    func moveSession(id: UUID, verticalPoints: CGFloat, hourHeight: CGFloat) {
        guard hourHeight > 0,
              let item = state.success?.timelineItems.first(where: { $0.id == id }) else {
            return
        }
        let rawMinutes = verticalPoints / hourHeight * 60
        let snapIntervalMinutes: CGFloat = 5
        let snappedMinutes = Int((rawMinutes / snapIntervalMinutes).rounded())
            * Int(snapIntervalMinutes)
        guard snappedMinutes != 0 else { return }

        let start = item.start.addingTimeInterval(Double(snappedMinutes) * 60)
        rescheduleSession(id: id, proposedStart: start)
    }

    func rescheduleSession(id: UUID, proposedStart: Date) {
        guard var success = state.success,
              let item = success.timelineItems.first(where: { $0.id == id }),
              let range = clampedRange(for: item, proposedStart: proposedStart),
              let index = success.sessions.firstIndex(where: { $0.id == id }),
              !state.isMutating else {
            return
        }
        guard range.start != item.start else { return }

        let original = success.sessions[index]
        let optimistic = Session(
            id: original.id,
            taskID: original.taskID,
            zoneID: original.zoneID,
            timeRange: range,
            blocking: true,
            status: original.status,
            firstCompletedAt: original.firstCompletedAt
        )

        state.isMutating = true
        state.failure = nil
        success.sessions[index] = optimistic
        state.success = success
        applyContent()

        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                let accepted = try await useCases.sessions.reschedule.execute(
                    sessionID: id,
                    newStart: range.start
                )
                replaceSession(accepted)
            } catch is CancellationError {
                replaceSession(original)
            } catch {
                replaceSession(original)
                state.failure = HomeFailureState(message: error.localizedDescription)
            }
        }
    }

    func setSessionLock(id: UUID, isLocked: Bool) {
        guard var success = state.success,
              !state.isMutating,
              let index = success.sessions.firstIndex(where: { $0.id == id }) else {
            return
        }

        let original = success.sessions[index]
        guard original.blocking != isLocked else { return }
        let optimistic = Session(
            id: original.id,
            taskID: original.taskID,
            zoneID: original.zoneID,
            timeRange: original.timeRange,
            blocking: isLocked,
            status: original.status,
            firstCompletedAt: original.firstCompletedAt
        )

        state.isMutating = true
        state.failure = nil
        success.sessions[index] = optimistic
        state.success = success
        applyContent()

        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                let accepted = try await useCases.sessions.setLock.execute(
                    sessionID: id,
                    isLocked: isLocked
                )
                replaceSession(accepted)
            } catch is CancellationError {
                replaceSession(original)
            } catch {
                replaceSession(original)
                state.failure = HomeFailureState(message: error.localizedDescription)
            }
        }
    }

    func setSessionCompletion(id: UUID, isCompleted: Bool) {
        guard var success = state.success,
              !state.isMutating,
              let index = success.sessions.firstIndex(where: { $0.id == id }) else {
            return
        }

        let original = success.sessions[index]
        let optimistic = Session(
            id: original.id,
            taskID: original.taskID,
            zoneID: original.zoneID,
            timeRange: original.timeRange,
            blocking: original.blocking,
            status: isCompleted ? .completed : .planned,
            firstCompletedAt: original.firstCompletedAt
        )

        state.isMutating = true
        state.failure = nil
        success.sessions[index] = optimistic
        state.success = success
        applyContent()

        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                let result = try await useCases.sessions.setCompletion.execute(
                    sessionID: id,
                    isCompleted: isCompleted
                )

                replaceSession(result.session)

                switch result {
                case .completed(let completion):
                    let reward = completion.reward

                    if true {
                        state.completionReward = HomeCompletionRewardState(
//                            pointsAwarded: reward.points.awarded ? reward.points.amount: nil,
//                            streak: reward.streak.updated ? reward.streak.newValue: nil,
                            pointsAwarded: reward.points.amount,
                            streak: reward.streak.newValue,
                            maxStreakBroken: true
                        )
                    }
                    
                    if reward.points.awarded, reward.points.amount > 0 {
                        state.completionRewardAnimation =
                            HomeCompletionRewardAnimation(
                                sessionID: completion.session.id,
                                oldPoints: reward.points.oldValue,
                                newPoints: reward.points.newValue
                            )
                        }

                case .uncompleted:
                    state.completionReward = nil
                    state.completionRewardAnimation = nil
                }
            } catch is CancellationError {
                replaceSession(original)
            } catch {
                replaceSession(original)
                state.failure = HomeFailureState(message: error.localizedDescription)
            }
        }
    }

    func deleteSession(id: UUID) {
        guard var success = state.success,
              let original = success.sessions.first(where: { $0.id == id }),
              !state.isMutating else {
            return
        }

        state.isMutating = true
        state.failure = nil
        success.sessions.removeAll { $0.id == id }
        state.success = success
        state.selectedSessionID = nil
        applyContent()

        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                try await useCases.sessions.delete.execute(sessionID: id)
            } catch is CancellationError {
                restoreSession(original)
            } catch {
                restoreSession(original)
                state.failure = HomeFailureState(message: error.localizedDescription)
            }
        }
    }

    private func replaceSession(_ updated: Session) {
        guard var success = state.success,
              let index = success.sessions.firstIndex(where: { $0.id == updated.id }) else {
            return
        }
        success.sessions[index] = updated
        state.success = success
        applyContent()
    }

    private func restoreSession(_ session: Session) {
        guard var success = state.success else { return }
        success.sessions.removeAll { $0.id == session.id }
        success.sessions.append(session)
        state.success = success
        applyContent()
    }

    private func clampedRange(
        for item: HomeTimelineItem,
        proposedStart: Date
    ) -> TimeRange? {
        guard let window = state.success?.timelineWindow else { return nil }
        let duration = item.end.timeIntervalSince(item.start)
        let latestStart = window.end.addingTimeInterval(-duration)
        guard latestStart >= window.start else { return nil }
        let start = min(max(proposedStart, window.start), latestStart)
        return try? TimeRange(start: start, end: start.addingTimeInterval(duration))
    }
}
