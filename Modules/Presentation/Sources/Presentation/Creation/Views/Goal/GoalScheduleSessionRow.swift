import Common
import SwiftUI

struct GoalScheduleSessionRow: View {
    let session: GoalScheduleReviewSession
    let zoneName: String?
    let onToggleSuggestion: () -> Void
    let onEdit: () -> Void
    let onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(AppFonts.captionIconBlack)
                Text(sessionLabel)
                    .font(AppFonts.caption2Bold)

                Spacer(minLength: 8)

                if session.isEdited {
                    Text(L10n.GoalCreation.edited)
                        .font(AppFonts.microHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
            .foregroundStyle(accentColor)

            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 12),
                surfaceColor: AppColors.surface,
                borderColor: accentColor.opacity(0.24),
                depthColor: accentColor.opacity(0.22),
                depthOffset: 3,
                contentInsets: EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            ) {
                HStack(spacing: 10) {
                    Button(action: onEdit) {
                        HStack(spacing: 10) {
                            Text(formattedInterval)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)

                            Spacer(minLength: 8)

                            Image(systemName: "pencil")
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if let onRemove {
                        Rectangle()
                            .fill(AppColors.divider)
                            .frame(width: 1, height: 24)

                        Button(role: .destructive, action: onRemove) {
                            Image(systemName: "trash")
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.destructive)
                                .frame(width: 42, height: 42)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.GoalCreation.removeSession)
                        .padding(.trailing, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !session.isManuallyEditedSuggestion {
                HStack(spacing: 8) {
                    if case .noZone = session.kind {
                        GoalScheduleSessionWarning(session: session)
                    } else {
                        Label(zoneLabel, systemImage: "square.3.layers.3d")
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.textSecondary)

                        Spacer(minLength: 8)

                        GoalScheduleSessionWarning(session: session)
                    }
                }

                if session.isSuggestion {
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
            }

        }
    }

    private var icon: String {
        if session.isManual { return "pin.fill" }
        return switch session.kind {
        case .manual: "pin.fill"
        case .proposed, .noZone, .overlap: "sparkles"
        }
    }

    private var accentColor: Color {
        if session.isManuallyEditedSuggestion {
            return AppColors.accentPurple
        }
        return switch session.kind {
        case .manual: AppColors.accentPurple
        case .proposed: AppColors.accentBlue
        case .noZone, .overlap: AppColors.warning
        }
    }

    private var sessionLabel: String {
        if session.isManual { return L10n.GoalCreation.manualSession }
        return switch session.kind {
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
