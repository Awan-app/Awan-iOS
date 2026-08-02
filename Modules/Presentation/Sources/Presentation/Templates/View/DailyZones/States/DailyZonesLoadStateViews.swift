import Common
import SwiftUI

struct DailyZonesLoadingView: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView().tint(AppColors.accentBlue)
            Text(L10n.Templates.loadingSchedules)
                .font(AppFonts.bodyBold)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DailyZonesFailureView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.warning)
            Text(L10n.Templates.loadFailure)
                .font(AppFonts.title3Black)
            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            AppButton(
                title: L10n.Templates.retry,
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                size: .compact,
                expandsHorizontally: false,
                onTap: onRetry
            )
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
