import Common
import SwiftUI

struct UnscheduledTasksDialog: View {
    let taskTitles: [String]
    let onAddSessions: () -> Void
    let onContinue: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            AppColors.shadow
                .opacity(0.56)
                .ignoresSafeArea()

            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 28),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.warning.opacity(0.34),
                depthColor: AppColors.warning.opacity(0.44),
                depthOffset: 7,
                contentInsets: EdgeInsets(
                    top: 24,
                    leading: 22,
                    bottom: 22,
                    trailing: 22
                )
            ) {
                VStack(spacing: 18) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppColors.warning)
                        .frame(width: 64, height: 64)
                        .background(
                            AppColors.warningSurface,
                            in: Circle()
                        )

                    VStack(spacing: 8) {
                        Text(L10n.GoalCreation.unresolvedTitle(taskTitles.count))
                            .font(AppFonts.title3Black)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(L10n.GoalCreation.unresolvedMessage)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    taskList

                    VStack(spacing: 14) {
                        AppButton(
                            title: L10n.GoalCreation.addSessions,
                            icon: "calendar.badge.plus",
                            color: AppColors.accentBlue,
                            onTap: onAddSessions
                        )

                        Button(action: onContinue) {
                            Text(L10n.GoalCreation.continueWithoutThem)
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.accentBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                        }
                        .buttonStyle(
                            AppDepthButtonStyle(
                                shape: .roundedRectangle(cornerRadius: 16),
                                surfaceColor: AppColors.surface,
                                borderColor: AppColors.accentBlue.opacity(0.32),
                                depthColor: AppColors.accentBlueDepth.opacity(0.62)
                            )
                        )

                        Button(L10n.Common.cancel, action: onCancel)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(minHeight: 32)
                    }
                }
            }
            .frame(maxWidth: 370)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }

    private var taskList: some View {
        ScrollView(showsIndicators: taskTitles.count > 3) {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(Array(taskTitles.enumerated()), id: \.offset) { _, title in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(AppColors.warning)

                        Text(title)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(14)
        }
        .frame(maxHeight: 156)
        .background(
            AppColors.warningSurface,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.warning.opacity(0.18), lineWidth: 1)
        }
    }
}
