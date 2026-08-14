import Common
import SwiftUI

struct SessionDetailsActionsView: View {
    let canSave: Bool
    let isSaving: Bool
    let isLocking: Bool
    let isLocked: Bool
    let onSave: () -> Void
    let onToggleLock: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) {
                SessionDetailsSaveButton(
                    canSave: canSave,
                    isSaving: isSaving,
                    onSave: onSave
                )
                SessionDetailsLockButton(
                    isLocked: isLocked,
                    isLoading: isLocking,
                    onToggleLock: onToggleLock
                )
            }

            VStack(spacing: 16) {
                SessionDetailsSaveButton(
                    canSave: canSave,
                    isSaving: isSaving,
                    onSave: onSave
                )
                SessionDetailsLockButton(
                    isLocked: isLocked,
                    isLoading: isLocking,
                    onToggleLock: onToggleLock
                )
            }
        }
    }
}

private struct SessionDetailsSaveButton: View {
    let canSave: Bool
    let isSaving: Bool
    let onSave: () -> Void

    var body: some View {
        AppButton(
            title: L10n.Home.saveChanges,
            icon: "checkmark",
            color: canSave ? AppColors.accentBlue : AppColors.buttonDisabled,
            shadowColor: canSave
                ? AppColors.accentBlueDepth
                : AppColors.buttonDisabledDepth,
            isLoading: isSaving,
            onTap: onSave
        )
        .disabled(!canSave)
    }
}

private struct SessionDetailsLockButton: View {
    let isLocked: Bool
    let isLoading: Bool
    let onToggleLock: () -> Void

    var body: some View {
        AppButton(
            title: isLocked ? L10n.Home.unlockSession : L10n.Home.lockSession,
            icon: isLocked ? "lock.open.fill" : "lock.fill",
            color: AppColors.surface,
            foregroundColor: AppColors.accentBlue,
            borderColor: AppColors.accentBlue.opacity(0.20),
            shadowColor: AppColors.accentBlueDepth.opacity(0.55),
            useGradient: false,
            isLoading: isLoading,
            onTap: onToggleLock
        )
    }
}
