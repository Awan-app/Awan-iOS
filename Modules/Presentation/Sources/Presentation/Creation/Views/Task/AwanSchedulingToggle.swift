import Common
import SwiftUI

struct AwanSchedulingToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isOn ? "wand.and.sparkles" : "clock.fill")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(isOn ? AppColors.onAccent : AppColors.accentBlue)
                    .frame(width: 38, height: 38)
                    .background(
                        isOn ? AppColors.accentBlue : AppColors.infoSurface,
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Home.chipAutoScheduled)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.brandDarkBlue)

                    Text(
                        isOn
                            ? L10n.Home.quickAddCaption
                            : L10n.Home.fieldStartsAtHint
                    )
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                }

                Spacer(minLength: 8)

                ZStack(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(
                            isOn
                                ? AppColors.accentBlue
                                : AppColors.brandDarkBlue.opacity(0.12)
                        )
                        .frame(width: 54, height: 31)

                    Circle()
                        .fill(AppColors.surface)
                        .frame(width: 25, height: 25)
                        .overlay {
                            Image(systemName: isOn ? "sparkles" : "clock")
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(
                                    isOn
                                        ? AppColors.accentBlue
                                        : AppColors.textSecondary
                                )
                        }
                        .padding(3)
                }
            }
            .padding(12)
            .background(
                AppColors.surface,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isOn
                            ? AppColors.accentBlue.opacity(0.55)
                            : AppColors.brandDarkBlue.opacity(0.12),
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityValue(isOn ? L10n.Home.yes : L10n.Home.no)
    }
}
