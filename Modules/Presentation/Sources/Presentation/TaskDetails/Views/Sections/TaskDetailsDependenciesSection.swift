import Common
import Domain
import SwiftUI

struct TaskDetailsDependenciesSection: View {
    let dependencies: [AwanTask]
    let onAdd: () -> Void
    let onRemove: (UUID) -> Void

    var body: some View {
        TaskDetailsSectionCard(title: L10n.TaskDetails.dependencies) {
            VStack(spacing: 12) {
                if dependencies.isEmpty {
                    Text(L10n.TaskDetails.noDependencies)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(dependencies) { task in
                        HStack(spacing: 10) {
                            Image(systemName: "link")
                                .foregroundStyle(AppColors.accentBlue)
                            Text(task.title)
                                .font(AppFonts.bodyBold)
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                onRemove(task.id)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(AppFonts.caption2Bold)
                                    .foregroundStyle(AppColors.destructive)
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(L10n.TaskDetails.removeDependency)
                        }
                    }
                }

                AppButton(
                    title: L10n.TaskDetails.addDependency,
                    icon: "plus",
                    color: AppColors.accentBlue,
                    onTap: onAdd
                )
            }
        }
    }
}
