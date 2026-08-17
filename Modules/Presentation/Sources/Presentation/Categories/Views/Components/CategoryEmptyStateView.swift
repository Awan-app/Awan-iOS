import Common
import SwiftUI

struct CategoryEmptyStateView: View {
    let onAddTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            AwanMascotView(state: .normal)
                .frame(width: 140, height: 110)

            Text(L10n.Categories.empty)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            AppButton(
                title: L10n.Categories.create,
                icon: "plus.circle.fill",
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                onTap: onAddTap
            )
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
}

