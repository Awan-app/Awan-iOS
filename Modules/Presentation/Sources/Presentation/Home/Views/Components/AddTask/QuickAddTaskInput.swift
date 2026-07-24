import Common
import Domain
import SwiftUI

struct QuickAddTaskInput: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Home.fieldTask.uppercased())
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textSecondary)

            TextField(L10n.Schedule.questNamePlaceholder, text: $text, axis: .vertical)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.brandDarkBlue)
                .lineLimit(2...3)
                .textFieldStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColors.accentBlue.opacity(0.12), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.2), lineWidth: 1.5)
        )
    }
}
