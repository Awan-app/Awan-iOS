import Common
import SwiftUI

struct QuestHeaderView: View {
    let selectedDayTitle: String
    let scheduledMinutes: Int
    let goalProgress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AWAN QUESTS")
                        .font(AppFonts.captionBlack)
                        .foregroundStyle(AppColors.accentGreen)
                        .tracking(1.2)
                    Text(selectedDayTitle)
                        .font(AppFonts.title2Black)
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AppColors.warning)
                    Text("7")
                        .font(AppFonts.headlineBlack)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.warningSurface, in: Capsule())
                .accessibilityLabel("Seven day streak")
            }

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(AppColors.divider, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: max(0.08, min(goalProgress, 1)))
                        .stroke(
                            AppColors.accentGreen,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: goalProgress)
                    Image(systemName: goalProgress > 0 ? "flag.checkered" : "star.fill")
                        .font(AppFonts.progressSymbol)
                        .foregroundStyle(
                            goalProgress > 0 ? AppColors.accentPurple : AppColors.reward
                        )
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(goalProgress > 0 ? "Quest chain" : "Today's adventure")
                            .font(AppFonts.headlineBlack)
                        Spacer()
                        Text("\(scheduledMinutes) min")
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AppColors.divider)
                            Capsule()
                                .fill(
                                    goalProgress > 0
                                        ? AppColors.accentPurple
                                        : AppColors.accentBlue
                                )
                                .frame(
                                    width: geometry.size.width * max(
                                        0.06,
                                        goalProgress > 0 ? goalProgress : min(Double(scheduledMinutes) / 240, 1)
                                    )
                                )
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding(18)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppColors.outline.opacity(0.05), lineWidth: 1.5)
        }
        .shadow(color: AppColors.shadow.opacity(0.07), radius: 18, y: 8)
    }
}
