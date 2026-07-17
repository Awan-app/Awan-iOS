import Common
import SwiftUI

struct GamifiedNudgeView: View {
    let model: TimelineNudgeModel
    let onAction: (TimelineNudgeAction) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(AppColors.textSecondary.opacity(0.25))
                .frame(width: 44, height: 5)

            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle().fill(AppColors.infoSurface)
                    Image(systemName: model.icon)
                        .font(AppFonts.nudgeSymbol)
                        .foregroundStyle(AppColors.accentBlue)
                        .symbolEffect(.bounce, options: .repeat(2))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.title)
                        .font(AppFonts.title3Black)
                    Text(model.message)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(model.actions) { action in
                    AppButton(
                        title: action.title,
                        icon: action.icon,
                        color: action.color,
                        size: .compact,
                        onTap: { onAction(action) }
                    )
                    .accessibilityIdentifier("nudge-action-\(action.title)")
                }
            }
            .padding(.bottom, 5)
        }
        .padding(18)
        .background(
            AppMaterials.nudgeSurface,
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppColors.onAccent.opacity(0.8), lineWidth: 1.5)
        }
        .shadow(color: AppColors.shadow.opacity(0.17), radius: 24, y: 12)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}
