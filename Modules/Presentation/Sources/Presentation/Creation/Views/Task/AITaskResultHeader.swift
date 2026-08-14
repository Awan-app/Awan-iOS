import Common
import SwiftUI

struct AITaskResultHeader: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Text(L10n.Home.aiTaskResultTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .accessibilityLabel(L10n.Common.close)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
    }
}
