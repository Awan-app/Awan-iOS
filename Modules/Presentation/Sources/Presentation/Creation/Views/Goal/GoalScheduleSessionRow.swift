import Common
import SwiftUI

struct GoalScheduleSessionRow: View {
    let session: GoalScheduleReviewSession
    let zoneName: String?
    let onToggleSuggestion: () -> Void
    let onEdit: () -> Void
    let onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onEdit) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(accentColor)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(sessionLabel)
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(accentColor)
                        Text(formattedInterval)
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                        Label(zoneLabel, systemImage: "square.3.layers.3d")
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer(minLength: 8)
                    if session.isEdited {
                        Text(L10n.GoalCreation.edited)
                            .font(AppFonts.microHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                    }
                    Image(systemName: "pencil")
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .multilineTextAlignment(.leading)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .roundedRectangle(cornerRadius: 12),
                    surfaceColor: AppColors.surface,
                    borderColor: accentColor.opacity(0.24),
                    depthColor: accentColor.opacity(0.22),
                    depthOffset: 3
                )
            )

            GoalScheduleSessionWarning(session: session)

            if isSuggestion {
                Toggle(
                    L10n.GoalCreation.acceptSuggestion,
                    isOn: Binding(
                        get: { session.isAccepted },
                        set: { _ in onToggleSuggestion() }
                    )
                )
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)
                .tint(AppColors.warning)
            }

            if let onRemove {
                Button(role: .destructive, action: onRemove) {
                    Label(L10n.GoalCreation.removeSession, systemImage: "trash")
                        .font(AppFonts.captionHeavy)
                }
                .foregroundStyle(AppColors.destructive)
            }
        }
    }

    private var isSuggestion: Bool {
        switch session.kind {
        case .noZone, .overlap: true
        case .proposed, .manual: false
        }
    }

    private var icon: String {
        switch session.kind {
        case .manual: "pin.fill"
        case .proposed: "sparkles"
        case .noZone, .overlap: "exclamationmark.triangle.fill"
        }
    }

    private var accentColor: Color {
        switch session.kind {
        case .manual: AppColors.accentPurple
        case .proposed: AppColors.accentBlue
        case .noZone, .overlap: AppColors.warning
        }
    }

    private var sessionLabel: String {
        switch session.kind {
        case .manual: L10n.GoalCreation.manualSession
        case .proposed, .noZone, .overlap: L10n.GoalCreation.aiSession
        }
    }

    private var zoneLabel: String {
        guard session.zoneID != nil else { return L10n.GoalCreation.noZone }
        return zoneName ?? L10n.GoalCreation.assignedZone
    }

    private var formattedInterval: String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.start, to: session.end)
    }
}
