import Common
import SwiftUI

struct CategoryEmptyStateView: View {
    let onAddTap: () -> Void

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            contentInsets: EdgeInsets(top: 32, leading: 24, bottom: 32, trailing: 24)
        ) {
            VStack(spacing: 16) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(AppColors.textSecondary)

                Text(L10n.Categories.empty)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                AppButton(
                    title: L10n.Categories.create,
                    icon: "plus.circle.fill",
                    color: AppColors.accentBlue,
                    foregroundColor: AppColors.onAccent,
                    onTap: onAddTap
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}
