import Common
import Domain
import SwiftUI

struct TaskDetailsGoalPickerSheet: View {
    let goals: [Goal]
    let onSelect: (Goal) -> Void
    let onDismiss: () -> Void
    @State private var searchQuery = ""

    var body: some View {
        AppSheet(
            sizing: .detents([.medium, .large]),
            backgroundColor: AppColors.sheetBackground
        ) {
            NavigationStack {
                VStack(spacing: 12) {
                    TaskDetailsPickerSearchField(
                        text: $searchQuery,
                        placeholder: L10n.TaskDetails.searchGoals
                    )
                    .padding(.horizontal, 16)

                    if filteredGoals.isEmpty {
                        TaskDetailsPickerEmptyView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredGoals) { goal in
                                    TaskDetailsPickerRow(
                                        title: goal.name,
                                        subtitle: goal.description,
                                        icon: "flag.fill"
                                    ) {
                                        onSelect(goal)
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
                .navigationTitle(L10n.TaskDetails.chooseGoal)
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

    private var filteredGoals: [Goal] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return goals }
        return goals.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || ($0.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}
