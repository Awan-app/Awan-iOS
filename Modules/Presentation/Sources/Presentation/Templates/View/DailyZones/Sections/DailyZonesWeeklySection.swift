import Common
import Domain
import SwiftUI

struct DailyZonesWeeklySection: View {
    let viewModel: DailyZonesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader

            if viewModel.state.templates.isEmpty {
                DailyZonesEmptyCard(
                    icon: "calendar.badge.plus",
                    title: L10n.Templates.noWeeklyTemplates,
                    message: L10n.Templates.noWeeklyTemplatesMessage,
                    actionTitle: L10n.Templates.createTemplate,
                    action: { viewModel.send(.presentCreation) }
                )
            } else {
                templatesStrip
                if let template = viewModel.selectedTemplate {
                    selectedTemplateWeekdays(template)
                    DailyZonesScheduleSection(viewModel: viewModel, editable: true)
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text(L10n.Templates.sectionTitle)
                .font(AppFonts.title2Black)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            AppButton(
                title: L10n.Templates.newButton,
                icon: "plus",
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                size: .compact,
                expandsHorizontally: false,
                onTap: { viewModel.send(.presentCreation) }
            )
        }
    }

    private var templatesStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.state.templates) { template in
                    TemplateCardView(
                        template: template,
                        isSelected: template.id == viewModel.state.selectedTemplateID,
                        onTap: { viewModel.send(.selectTemplate(template.id)) }
                    )
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 2)
        }
    }

    private func selectedTemplateWeekdays(_ template: Template) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.Templates.activeDaysTitle)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button { viewModel.send(.presentTemplateEditor) } label: {
                    Label(L10n.Templates.edit, systemImage: "pencil")
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.accentBlue)
                }
                .buttonStyle(.plain)
            }

            ActiveDaysChipsView(
                activeDays: template.daysOfWeek,
                today: viewModel.todayWeekday
            )
            .animation(.snappy(duration: 0.25), value: template.daysOfWeek)
        }
        .padding(.horizontal, 2)
    }
}
