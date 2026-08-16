import Common
import Domain
import SwiftUI

struct TaskDetailsSettingsSection: View {
    @Binding var mandatory: Bool
    @Binding var isSplittable: Bool
    let categories: [TaskCategory]
    let zones: [Zone]
    let selectedCategoryID: UUID?
    let categoryErrorMessage: String?
    let onSelectCategory: (UUID?) -> Void
    let onRetryCategories: () -> Void

    var body: some View {
        TaskDetailsSectionCard(title: L10n.TaskDetails.settings) {
            VStack(spacing: 0) {
                TaskDetailsCategoryRow(
                    categories: categories,
                    zones: zones,
                    selectedCategoryID: selectedCategoryID,
                    errorMessage: categoryErrorMessage,
                    onRetry: onRetryCategories,
                    onSelect: onSelectCategory
                )

                Divider().background(AppColors.divider)

                TaskDetailsToggleRow(
                    icon: "exclamationmark.circle.fill",
                    title: L10n.TaskDetails.mandatory,
                    subtitle: L10n.TaskDetails.mandatoryHint,
                    isOn: $mandatory
                )

                Divider().background(AppColors.divider)

                TaskDetailsToggleRow(
                    icon: "scissors",
                    title: L10n.TaskDetails.allowSplitting,
                    subtitle: L10n.TaskDetails.allowSplittingHint,
                    isOn: $isSplittable
                )
            }
        }
    }
}

private struct TaskDetailsCategoryRow: View {
    let categories: [TaskCategory]
    let zones: [Zone]
    let selectedCategoryID: UUID?
    let errorMessage: String?
    let onRetry: () -> Void
    let onSelect: (UUID?) -> Void
    @State private var isPickerPresented = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 32, height: 32)
                .background(AppColors.infoSurface, in: Circle())

            Text(L10n.Schedule.category)
                .font(AppFonts.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 8)

            Button { isPickerPresented = true } label: {
                HStack(spacing: 8) {
                    categoryIndicator

                    Text(selectedCategoryName)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .lineLimit(1)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 38)
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .capsule,
                    surfaceColor: AppColors.infoSurface,
                    borderColor: AppColors.accentBlue.opacity(0.22),
                    depthColor: AppColors.accentBlueDepth.opacity(0.45),
                    depthOffset: 3
                )
            )
            .padding(.bottom, 3)
            .popover(isPresented: $isPickerPresented, arrowEdge: .bottom) {
                ProposedCategoryPickerPopover(
                    categories: categories,
                    zones: zones,
                    selectedCategoryID: selectedCategoryID,
                    errorMessage: errorMessage,
                    onRetry: onRetry,
                    onSelect: { categoryID in
                        onSelect(categoryID)
                        isPickerPresented = false
                    }
                )
                .presentationCompactAdaptation(.popover)
            }
        }
        .padding(.vertical, 8)
    }

    private var selectedCategoryName: String {
        guard let selectedCategoryID else { return L10n.Schedule.standalone }
        return categories.first { $0.id == selectedCategoryID }?.name
            ?? L10n.Schedule.chooseCategory
    }

    @ViewBuilder
    private var categoryIndicator: some View {
        if let selectedCategoryID {
            ProposedZoneColorSwatches(colors: zoneColors(for: selectedCategoryID))
        } else {
            Circle()
                .fill(AppColors.runtimeFallback)
                .frame(width: 10, height: 10)
        }
    }

    private func zoneColors(for categoryID: UUID) -> [ZoneColor] {
        zones.first { $0.category?.id == categoryID }.map { [$0.color] } ?? []
    }
}

private struct TaskDetailsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 32, height: 32)
                    .background(AppColors.infoSurface, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(subtitle)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .tint(AppColors.accentBlue)
        .padding(.vertical, 8)
    }
}
