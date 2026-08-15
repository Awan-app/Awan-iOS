import Common
import SwiftUI

struct GoalScheduleEmptySessionRow: View {
    let unscheduledReason: String?
    let onAddSession: () -> Void

    @State private var showsReason = false

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 12),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.24),
            depthColor: AppColors.accentBlue.opacity(0.2),
            depthOffset: 3,
            contentInsets: EdgeInsets(
                top: 8,
                leading: 14,
                bottom: 8,
                trailing: 8
            )
        ) {
            HStack(spacing: 12) {
                Text(L10n.GoalCreation.noSessionsAdded)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)

                if let unscheduledReason {
                    Button {
                        showsReason = true
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(AppFonts.captionIconBlack)
                            .foregroundStyle(AppColors.warning)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.GoalCreation.whyUnscheduled)
                    .popover(
                        isPresented: $showsReason,
                        attachmentAnchor: .rect(.bounds),
                        arrowEdge: .bottom
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(
                                L10n.GoalCreation.whyUnscheduled,
                                systemImage: "calendar.badge.exclamationmark"
                            )
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.warning)

                            Text(unscheduledReason)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(width: 290, alignment: .leading)
                        .background(AppColors.surface)
                        .presentationCompactAdaptation(.popover)
                    }
                }

                Spacer(minLength: 8)

                Button(action: onAddSession) {
                    Image(systemName: "plus")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.onAccent)
                        .frame(width: 38, height: 38)
                        .background(AppColors.accentBlue, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.GoalCreation.addSession)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
