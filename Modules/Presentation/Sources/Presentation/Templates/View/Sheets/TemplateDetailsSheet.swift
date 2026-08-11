import Common
import SwiftUI

struct TemplateDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyZonesViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let form = viewModel.state.templateForm {
                        AppDepthSurface(
                            shape: .roundedRectangle(cornerRadius: 20),
                            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
                        ) {
                            VStack(alignment: .leading, spacing: 18) {
                                Text(L10n.Templates.templateName)
                                    .font(AppFonts.subheadlineHeavy)
                                AppTextField(
                                    text: Binding(
                                        get: { viewModel.state.templateForm?.name ?? "" },
                                        set: { viewModel.send(.setTemplateName($0)) }
                                    ),
                                    placeholder: L10n.Templates.templateNamePlaceholder
                                )

                                Text(L10n.Templates.activeDaysTitle)
                                    .font(AppFonts.subheadlineHeavy)
                                ActiveDaysChipsView(
                                    activeDays: form.weekdays,
                                    today: viewModel.todayWeekday,
                                    availability: viewModel.state.weekdayAvailability,
                                    onToggle: { viewModel.send(.toggleTemplateWeekday($0)) }
                                )
                            }
                        }

                        if let message = form.conflictMessage {
                            Text(message)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.warning)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(AppColors.warningSurface, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    AppButton(
                        title: L10n.Templates.saveTemplateDetails,
                        icon: "checkmark.circle.fill",
                        color: AppColors.accentBlue,
                        foregroundColor: AppColors.onAccent,
                        onTap: { viewModel.send(.submitTemplateDetails) }
                    )

                    AppButton(
                        title: L10n.Templates.deleteTemplate,
                        icon: "trash.fill",
                        color: AppColors.destructive,
                        foregroundColor: AppColors.onAccent,
                        onTap: { viewModel.send(.requestDeleteTemplate) }
                    )
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
            .navigationTitle(L10n.Templates.editTemplate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) {
                        viewModel.send(.dismissSheet)
                        dismiss()
                    }
                    .font(AppFonts.bodyBold)
                }
            }
        }
    }
}
