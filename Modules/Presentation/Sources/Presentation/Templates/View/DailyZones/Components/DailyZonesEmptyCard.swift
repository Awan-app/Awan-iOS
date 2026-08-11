import Common
import SwiftUI

struct DailyZonesEmptyCard: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var compact = false
    var action: (() -> Void)?

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            contentInsets: compact
                ? EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
                : EdgeInsets(top: 20, leading: 18, bottom: 20, trailing: 18)
        ) {
            if compact {
                compactContent
            } else {
                regularContent
            }
        }
    }

    private var compactContent: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(AppFonts.statSymbol)
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 34, height: 34)
                .background(
                    AppColors.accentBlue.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFonts.subheadlineBlack)
                    .foregroundStyle(AppColors.textPrimary)
                Text(message)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                compactAction
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    private var regularContent: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(AppFonts.nudgeSymbol)
                .foregroundStyle(AppColors.accentBlue)
            Text(title)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            regularAction
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var compactAction: some View {
        if let actionTitle, let action {
            Button(action: action) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text(actionTitle)
                }
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)
                .padding(.vertical, 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var regularAction: some View {
        if let actionTitle, let action {
            AppButton(
                title: actionTitle,
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                size: .compact,
                expandsHorizontally: false,
                onTap: action
            )
        }
    }
}
