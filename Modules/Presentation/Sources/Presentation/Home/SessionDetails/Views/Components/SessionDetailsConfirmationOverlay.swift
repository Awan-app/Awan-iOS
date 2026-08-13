import Common
import SwiftUI

struct SessionDetailsConfirmationOverlay: View {
    let confirmation: SessionDetailsConfirmation
    let isDeleting: Bool
    let onCancel: () -> Void
    let onConfirmDelete: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        ZStack {
            AppColors.shadow.opacity(0.54)
                .ignoresSafeArea()

            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 28),
                surfaceColor: AppColors.sheetBackground,
                borderColor: AppColors.outline.opacity(0.12),
                depthColor: AppColors.shadow.opacity(0.34),
                depthOffset: 7,
                contentInsets: EdgeInsets(
                    top: 26,
                    leading: 24,
                    bottom: 28,
                    trailing: 24
                )
            ) {
                switch confirmation {
                case .delete:
                    SessionDeleteConfirmationContent(
                        isDeleting: isDeleting,
                        onCancel: onCancel,
                        onDelete: onConfirmDelete
                    )
                case .discardChanges:
                    SessionDiscardConfirmationContent(
                        onKeepEditing: onCancel,
                        onDiscard: onDiscard
                    )
                }
            }
            .frame(maxWidth: 410)
            .padding(.horizontal, 24)
        }
    }
}

private struct SessionDeleteConfirmationContent: View {
    let isDeleting: Bool
    let onCancel: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(AppFonts.title2Black)
                    .foregroundStyle(AppColors.destructive)
                    .frame(width: 52, height: 52)
                    .background(
                        AppColors.destructive.opacity(0.12),
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Home.deleteSessionTitle)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(L10n.Home.deleteSessionMessage)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 16) {
                AppButton(
                    title: L10n.Common.cancel,
                    color: AppColors.surface,
                    foregroundColor: AppColors.accentBlue,
                    borderColor: AppColors.accentBlue.opacity(0.20),
                    shadowColor: AppColors.accentBlueDepth.opacity(0.48),
                    useGradient: false,
                    onTap: onCancel
                )

                AppButton(
                    title: L10n.Home.deleteSession,
                    icon: "trash.fill",
                    color: AppColors.destructive,
                    isLoading: isDeleting,
                    onTap: onDelete
                )
            }
        }
    }
}

private struct SessionDiscardConfirmationContent: View {
    let onKeepEditing: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "exclamationmark.triangle")
                .font(AppFonts.titleBlack)
                .foregroundStyle(AppColors.warning)
                .frame(width: 64, height: 64)
                .background(AppColors.warningSurface, in: Circle())

            Text(L10n.Home.closeSessionDetailsTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(L10n.Home.closeSessionDetailsMessage)
                .font(AppFonts.bodySemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            AppButton(
                title: L10n.Home.keepEditing,
                color: AppColors.accentBlue,
                onTap: onKeepEditing
            )

            AppButton(
                title: L10n.Home.discardAndClose,
                color: AppColors.surface,
                foregroundColor: AppColors.destructive,
                borderColor: AppColors.outline.opacity(0.14),
                shadowColor: AppColors.outline.opacity(0.18),
                useGradient: false,
                onTap: onDiscard
            )
        }
    }
}
