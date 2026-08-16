import Common
import SwiftUI

struct TaskDetailsPickerSearchField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 16),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.10),
            depthColor: AppColors.outline.opacity(0.08),
            depthOffset: 3,
            contentInsets: EdgeInsets(top: 11, leading: 13, bottom: 11, trailing: 13)
        ) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)
                TextField(placeholder, text: $text)
                    .font(AppFonts.bodySemibold)
                    .textFieldStyle(.plain)
            }
        }
    }
}

struct TaskDetailsPickerRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 18),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.accentBlue.opacity(0.18),
                depthColor: AppColors.accentBlueDepth.opacity(0.35),
                depthOffset: 4,
                contentInsets: EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
            ) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundStyle(AppColors.accentBlue)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(AppFonts.bodyBold)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct TaskDetailsPickerEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            Text(L10n.TaskDetails.noMatches)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
