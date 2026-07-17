import SwiftUI

public struct AppCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(18)
            .background(
                AppColors.surface,
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppColors.outline.opacity(0.06), lineWidth: 1.5)
            }
            .shadow(color: AppColors.shadow.opacity(0.08), radius: 18, y: 8)
    }
}

#Preview("AppCard Light") {
    AppCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily quest")
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
            Text("Build something meaningful today.")
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("AppCard Dark") {
    AppCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily quest")
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
            Text("Build something meaningful today.")
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
