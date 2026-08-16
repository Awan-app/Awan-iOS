import Common
import Domain
import SwiftUI

struct TaskDetailsDependencyPickerSheet: View {
    let tasks: [AwanTask]
    let sourceName: String
    let onSelect: (AwanTask) -> Void
    let onDismiss: () -> Void
    @State private var searchQuery = ""

    var body: some View {
        AppSheet(
            sizing: .detents([.medium, .large]),
            backgroundColor: AppColors.sheetBackground
        ) {
            NavigationStack {
                VStack(spacing: 12) {
                    TaskDetailsDependencySourceView(sourceName: sourceName)
                        .padding(.horizontal, 16)

                    TaskDetailsPickerSearchField(
                        text: $searchQuery,
                        placeholder: L10n.TaskDetails.searchTasks
                    )
                    .padding(.horizontal, 16)

                    if filteredTasks.isEmpty {
                        TaskDetailsPickerEmptyView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredTasks) { task in
                                    TaskDetailsPickerRow(
                                        title: task.title,
                                        subtitle: task.description,
                                        icon: "link.badge.plus"
                                    ) {
                                        onSelect(task)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.top, 12)
                .background(alignment: .top) {
                    AppCloudsHorizon(height: 220)
                        .frame(maxWidth: .infinity)
                }
                .background(AppColors.sheetBackground.ignoresSafeArea())
                .navigationTitle(L10n.TaskDetails.chooseDependency)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(L10n.Common.cancel, action: onDismiss)
                            .font(AppFonts.subheadlineHeavy)
                    }
                }
            }
        }
    }

    private var filteredTasks: [AwanTask] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return tasks }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || ($0.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}

private struct TaskDetailsDependencySourceView: View {
    let sourceName: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "tray.full.fill")
                .font(.system(size: 12, weight: .bold))

            Text(L10n.TaskDetails.pickingDependenciesFrom(sourceName))
                .lineLimit(1)
        }
        .font(AppFonts.captionHeavy)
        .foregroundStyle(AppColors.accentBlue)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(AppColors.infoSurface, in: Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
