import Common
import SwiftUI

struct TaskDetailsInformationSection: View {
    @Binding var title: String
    @Binding var description: String

    var body: some View {
        TaskDetailsSectionCard(title: L10n.TaskDetails.taskInformation) {
            VStack(spacing: 10) {
                TextField(L10n.TaskDetails.titlePlaceholder, text: $title)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.textPrimary)
                    .textFieldStyle(.plain)

                Divider().background(AppColors.divider)

                TextField(
                    L10n.TaskDetails.descriptionPlaceholder,
                    text: $description,
                    axis: .vertical
                )
                .font(AppFonts.bodySemibold)
                .foregroundStyle(AppColors.textSecondary)
                .textFieldStyle(.plain)
                .lineLimit(2...6)
            }
        }
    }
}

struct TaskDetailsSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.10),
            depthColor: AppColors.outline.opacity(0.10),
            borderWidth: 1.5,
            depthOffset: 4,
            contentInsets: EdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Text(title.uppercased())
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                content
            }
        }
    }
}
