import Common
import SwiftUI

struct AITaskResultSheet: View {
    let item: AITaskSheetItem
    let onDismiss: () -> Void

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.Home.taskDetails) {
                    if let description = item.task.description, !description.isEmpty {
                        LabeledContent(L10n.Home.description, value: description)
                    }

                    if let category = item.task.category {
                        LabeledContent(L10n.Home.aiTaskCategory, value: category.name)
                    }

                    LabeledContent(
                        L10n.Home.estimatedDuration,
                        value: L10n.Home.minutesShort(item.task.estimatedDuration)
                    )
                }

                Section {
                    LabeledContent(
                        L10n.Home.startTime,
                        value: Self.timeFormatter.string(from: item.startTime)
                    )

                    LabeledContent(
                        L10n.Home.endTime,
                        value: Self.timeFormatter.string(from: item.endTime)
                    )
                } header: {
                    Text(Self.dateFormatter.string(from: item.startTime))
                }
            }
            .navigationTitle(item.task.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.close, action: onDismiss)
                }
            }
        }
    }
}

#if DEBUG
import Domain
extension AITaskSheetItem {
    static var mock: AITaskSheetItem {
        AITaskSheetItem(
            task: AITask(
                id: UUID(),
                title: "Build login page",
                description: "Create a login page with email and password fields",
                estimatedDuration: 60,
                status: "SCHEDULED",
                mandatory: true,
                estimatedPoints: 20,
                isSplittable: false,
                goalID: UUID(),
                dependencyIDs: [],
                category: TaskCategory(id: UUID(), name: "Development")
            ),
            startTime: Date()
        )
    }
}

#Preview {
    AITaskResultSheet(item: .mock, onDismiss: {})
}
#endif
