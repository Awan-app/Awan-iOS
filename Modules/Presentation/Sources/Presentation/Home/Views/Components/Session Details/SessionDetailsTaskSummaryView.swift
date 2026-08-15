import Common
import Domain
import SwiftUI

struct SessionDetailsTaskSummaryView: View {
    let task: AwanTask
    let color: Color
    let arePointsClaimed: Bool
    let onClose: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.outline.opacity(0.12),
                        depthColor: AppColors.outline.opacity(0.16),
                        depthOffset: 3
                    )
                )
                .accessibilityLabel(L10n.Common.close)

                if let category = task.category {
                    SessionDetailsInfoChip(
                        title: category.name.uppercased(),
                        icon: nil,
                        foregroundColor: color,
                        surfaceColor: AppColors.surface,
                        depthColor: color,
                        borderColor: color,
                        borderWidth: 1.5
                    )
                }

                SessionDetailsInfoChip(
                    title: L10n.Home.pointsValue(task.estimatedPoints),
                    icon: arePointsClaimed ? "checkmark" : "star.fill",
                    foregroundColor: AppColors.reward,
                    surfaceColor: AppColors.surface,
                    depthColor: AppColors.reward,
                    borderColor: AppColors.reward,
                    borderWidth: 1.5
                )

                Spacer(minLength: 4)

                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.destructive)
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.destructive,
                        depthColor: AppColors.destructive,
                        borderWidth: 1.5,
                        depthOffset: 4
                    )
                )
                .accessibilityLabel(L10n.Home.deleteSession)
            }

            Text(task.title)
                .font(AppFonts.title2Black)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let description = task.description, !description.isEmpty {
                Text(description)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct SessionDetailsInfoChip: View {
    let title: String
    let icon: String?
    let foregroundColor: Color
    let surfaceColor: Color
    let depthColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat

    init(
        title: String,
        icon: String?,
        foregroundColor: Color,
        surfaceColor: Color,
        depthColor: Color,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1
    ) {
        self.title = title
        self.icon = icon
        self.foregroundColor = foregroundColor
        self.surfaceColor = surfaceColor
        self.depthColor = depthColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    var body: some View {
        AppDepthSurface(
            shape: .capsule,
            surfaceColor: surfaceColor,
            borderColor: borderColor ?? foregroundColor.opacity(0.18),
            depthColor: depthColor,
            borderWidth: borderWidth,
            depthOffset: 3,
            contentInsets: EdgeInsets(
                top: 7,
                leading: 11,
                bottom: 7,
                trailing: 11
            )
        ) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .lineLimit(1)
            }
            .font(AppFonts.captionHeavy)
            .foregroundStyle(foregroundColor)
        }
    }
}
