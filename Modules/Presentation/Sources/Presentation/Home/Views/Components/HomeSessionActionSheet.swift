import Common
import Domain
import SwiftUI

struct HomeSessionActionSheet: View {
    let item: HomeTimelineItem
    let task: AwanTask
    let window: HomeTimelineWindow?
    let isMutating: Bool
    let onReschedule: (Date) -> Void
    let onSetLock: (Bool) -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    @State private var proposedStart: Date
    @State private var showsDeleteConfirmation = false

    init(
        item: HomeTimelineItem,
        task: AwanTask,
        window: HomeTimelineWindow?,
        isMutating: Bool,
        onReschedule: @escaping (Date) -> Void,
        onSetLock: @escaping (Bool) -> Void,
        onDelete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.item = item
        self.task = task
        self.window = window
        self.isMutating = isMutating
        self.onReschedule = onReschedule
        self.onSetLock = onSetLock
        self.onDelete = onDelete
        self.onDismiss = onDismiss
        _proposedStart = State(initialValue: item.start)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.Home.taskDetails) {
                    if let description = task.description, !description.isEmpty {
                        LabeledContent(L10n.Home.description, value: description)
                    }
                    LabeledContent(L10n.Home.status, value: statusLabel)
                    LabeledContent(
                        L10n.Home.duration,
                        value: L10n.Home.minutesShort(task.duration.minutes)
                    )
                    LabeledContent(
                        L10n.Home.points,
                        value: L10n.Home.pointsValue(task.estimatedPoints)
                    )
                    LabeledContent(
                        L10n.Home.mandatory,
                        value: booleanLabel(task.mandatory)
                    )
                    LabeledContent(
                        L10n.Home.canSplit,
                        value: booleanLabel(task.isSplittable)
                    )
                }

                Section {
                    DatePicker(
                        L10n.Home.startTime,
                        selection: $proposedStart,
                        in: allowedStartRange,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    Button(L10n.Home.reschedule) {
                        onReschedule(proposedStart)
                    }
                    .disabled(isMutating || proposedStart == item.start)
                }

                Section {
                    Button(item.blocking ? L10n.Home.unlockSession : L10n.Home.lockSession) {
                        onSetLock(!item.blocking)
                    }
                    .disabled(isMutating)

                    Button(L10n.Home.deleteSession, role: .destructive) {
                        showsDeleteConfirmation = true
                    }
                    .disabled(isMutating)
                }
            }
            .navigationTitle(item.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.close, action: onDismiss)
                }
            }
        }
        .confirmationDialog(
            L10n.Home.deleteSessionConfirmation,
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.Home.deleteSession, role: .destructive, action: onDelete)
            Button(L10n.Common.cancel, role: .cancel) {}
        }
    }

    private var allowedStartRange: ClosedRange<Date> {
        guard let window else { return item.start...item.start }
        let latest = window.end.addingTimeInterval(-item.end.timeIntervalSince(item.start))
        return window.start...max(window.start, latest)
    }

    private var statusLabel: String {
        switch task.status {
        case .drafted:
            L10n.Home.statusDrafted
        case .active:
            L10n.Home.statusActive
        case .completed:
            L10n.Home.statusCompleted
        case .cancelled:
            L10n.Home.statusCancelled
        }
    }

    private func booleanLabel(_ value: Bool) -> String {
        value ? L10n.Home.yes : L10n.Home.no
    }
}



import Domain
extension HomeTimelineItem {
    static var mock: HomeTimelineItem {
        HomeTimelineItem(
            id: UUID(),
            taskID: UUID(),
            title: "Test Timeline Item",
            points: 10,
            color: AppColors.accentBlue,
            start: Date(),
            end: Date().addingTimeInterval(3600),
            blocking: false,
            status: .planned,
            lane: 0,
            laneCount: 1,
            showsCompletionPoints: true
        )
    }
}

#Preview {
    HomeSessionActionSheet(
        item: .mock,
        task: .mock,
        window: nil,
        isMutating: false,
        onReschedule: { _ in },
        onSetLock: { _ in },
        onDelete: {},
        onDismiss: {}
    )
    .padding()
}
