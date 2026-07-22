import Domain
import Foundation

extension HomeViewModel {
    func moveSession(id: UUID, verticalPoints: CGFloat, hourHeight: CGFloat) {
        guard hourHeight > 0,
              let item = state.timelineItems.first(where: { $0.id == id }) else {
            return
        }
        let rawMinutes = verticalPoints / hourHeight * 60
        let snappedMinutes = Int((rawMinutes / 15).rounded()) * 15
        guard snappedMinutes != 0 else { return }

        let start = item.start.addingTimeInterval(Double(snappedMinutes) * 60)
        rescheduleSession(id: id, proposedStart: start)
    }

    func rescheduleSession(id: UUID, proposedStart: Date) {
        guard let item = state.timelineItems.first(where: { $0.id == id }),
              let range = clampedRange(for: item, proposedStart: proposedStart),
              let index = sessions.firstIndex(where: { $0.id == id }),
              !state.isMutating else {
            return
        }
        guard range.start != item.start else { return }

        let original = sessions[index]
        let optimistic = Session(
            id: original.id,
            taskID: original.taskID,
            zoneID: original.zoneID,
            timeRange: range,
            blocking: true,
            status: original.status
        )

        state.isMutating = true
        state.errorMessage = nil
        sessions[index] = optimistic
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
                state.errorMessage = error.localizedDescription
            }
        }
    }

    func setSessionLock(id: UUID, isLocked: Bool) {
        performMutation {
            let updated = try await self.useCases.sessions.setLock.execute(
                sessionID: id,
                isLocked: isLocked
            )
            self.replaceSession(updated)
        }
    }

    func setSessionCompletion(id: UUID, isCompleted: Bool) {
        guard !state.isMutating,
              let index = sessions.firstIndex(where: { $0.id == id }) else {
            return
        }

        let original = sessions[index]
        let optimistic = Session(
            id: original.id,
            taskID: original.taskID,
            zoneID: original.zoneID,
            timeRange: original.timeRange,
            blocking: original.blocking,
            status: isCompleted ? .completed : .planned
        )

        state.isMutating = true
        state.errorMessage = nil
        sessions[index] = optimistic
        applyContent()

        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                let accepted = try await useCases.sessions.setCompletion.execute(
                    sessionID: id,
                    isCompleted: isCompleted
                )
                replaceSession(accepted)
            } catch is CancellationError {
                replaceSession(original)
            } catch {
                replaceSession(original)
                state.errorMessage = error.localizedDescription
            }
        }
    }

    func deleteSession(id: UUID) {
        performMutation {
            try await self.useCases.sessions.delete.execute(sessionID: id)
            self.sessions.removeAll { $0.id == id }
            self.state.selectedSessionID = nil
            self.applyContent()
        }
    }

    private func performMutation(
        _ operation: @escaping @MainActor () async throws -> Void
    ) {
        guard !state.isMutating else { return }
        state.isMutating = true
        state.errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                try await operation()
            } catch is CancellationError {
                return
            } catch {
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func replaceSession(_ updated: Session) {
        guard let index = sessions.firstIndex(where: { $0.id == updated.id }) else { return }
        sessions[index] = updated
        applyContent()
    }

    private func clampedRange(
        for item: HomeTimelineItem,
        proposedStart: Date
    ) -> TimeRange? {
        guard let window = state.timelineWindow else { return nil }
        let duration = item.end.timeIntervalSince(item.start)
        let latestStart = window.end.addingTimeInterval(-duration)
        guard latestStart >= window.start else { return nil }
        let start = min(max(proposedStart, window.start), latestStart)
        return try? TimeRange(start: start, end: start.addingTimeInterval(duration))
    }
}
