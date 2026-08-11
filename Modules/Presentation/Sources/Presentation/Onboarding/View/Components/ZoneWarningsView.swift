import SwiftUI
import Common

struct ZoneWarningsView: View {
    let showCategoryRequired: Bool
    let showOverlapError: Bool
    let showOutsideHoursWarning: Bool

    var body: some View {
        if showCategoryRequired {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(L10n.Onboarding.zoneCategoryRequired)
                    .font(AppFonts.subheadlineBold)
            }
            .foregroundStyle(AppColors.warning)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppColors.warning.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        } else if showOverlapError {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(L10n.Onboarding.zoneOverlapError)
                    .font(AppFonts.subheadlineBold)
            }
            .foregroundStyle(AppColors.destructive)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppColors.destructive.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        } else if showOutsideHoursWarning {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(L10n.Onboarding.outOfBoundsWarning)
                    .font(AppFonts.subheadlineBold)
            }
            .foregroundStyle(AppColors.warning)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppColors.warning.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}


#Preview {
    ZoneWarningsView(
        showCategoryRequired: true,
        showOverlapError: false,
        showOutsideHoursWarning: true
    )
        .padding()
}
