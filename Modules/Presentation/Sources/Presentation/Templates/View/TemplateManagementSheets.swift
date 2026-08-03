import Common
import Domain
import SwiftUI

struct TemplateCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyZonesViewModel
    let isEditingOverride: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !isEditingOverride {
                        kindPicker
                    }
                    formCard
                    if let message = viewModel.state.creationForm?.conflictMessage {
                        warning(message)
                    }
                    submitButton
                    if isEditingOverride {
                        destructiveButton(
                            title: L10n.Templates.useWeeklyRoutine,
                            action: { viewModel.send(.requestDeleteOverride) }
                        )
                    }
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
            .navigationTitle(isEditingOverride ? L10n.Templates.editOverride : L10n.Templates.newSchedule)
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

    private var kindPicker: some View {
        AppSegmentedPicker(
            selection: Binding(
                get: { viewModel.state.creationForm?.kind ?? .weekly },
                set: { viewModel.send(.setCreationKind($0)) }
            ),
            items: [
                .init(
                    value: .weekly,
                    title: L10n.Templates.weeklyRoutine,
                    icon: "calendar"
                ),
                .init(
                    value: .override,
                    title: L10n.Templates.dateOverride,
                    icon: "calendar.badge.clock"
                )
            ]
        )
    }

    @ViewBuilder
    private var formCard: some View {
        if let form = viewModel.state.creationForm {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 20),
                contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
            ) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(form.kind == .weekly ? L10n.Templates.templateName : L10n.Templates.overrideName)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    AppTextField(
                        text: Binding(
                            get: { viewModel.state.creationForm?.name ?? "" },
                            set: { viewModel.send(.setCreationName($0)) }
                        ),
                        placeholder: form.kind == .weekly
                            ? L10n.Templates.templateNamePlaceholder
                            : L10n.Templates.overrideNamePlaceholder
                    )

                    if form.kind == .weekly {
                        weeklyDays(form)
                    } else {
                        overrideDate(form)
                    }
                }
            }
        }
    }

    private func weeklyDays(_ form: TemplateCreationForm) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Templates.activeDaysTitle)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)
            Text(L10n.Templates.freeDaysHint)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textSecondary)
            ActiveDaysChipsView(
                activeDays: form.weekdays,
                today: viewModel.todayWeekday,
                availability: viewModel.state.weekdayAvailability,
                onToggle: { viewModel.send(.toggleCreationWeekday($0)) }
            )
            if !viewModel.state.weekdayAvailability.contains(where: \.isAvailable) {
                Text(L10n.Templates.noFreeDays)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.warning)
            }
            ForEach(
                viewModel.state.weekdayAvailability.filter { !$0.isAvailable },
                id: \.weekday
            ) { item in
                if let name = item.occupyingTemplateName {
                    Text(L10n.Templates.occupiedDay(item.weekday.localizedShortName, template: name))
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private func overrideDate(_ form: TemplateCreationForm) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Templates.overrideDate)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)
            AppDatePickerField(
                selection: Binding(
                    get: { viewModel.state.creationForm?.date ?? viewModel.minimumOverrideDate },
                    set: { viewModel.send(.setCreationDate($0)) }
                ),
                title: L10n.Templates.overrideDate,
                in: viewModel.minimumOverrideDate...Date.distantFuture
            )
            .environment(\.timeZone, viewModel.scheduleTimeZone)
        }
    }

    private var submitButton: some View {
        AppButton(
            title: isEditingOverride ? L10n.Templates.saveOverride : L10n.Templates.createSchedule,
            icon: "checkmark.circle.fill",
            color: AppColors.accentBlue,
            foregroundColor: AppColors.onAccent,
            onTap: {
                viewModel.send(isEditingOverride ? .submitOverrideDetails : .submitCreation)
            }
        )
        .disabled(viewModel.state.creationForm?.isSubmitting == true)
    }

    private func warning(_ message: String) -> some View {
        Text(message)
            .font(AppFonts.caption2Bold)
            .foregroundStyle(AppColors.warning)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(AppColors.warningSurface, in: RoundedRectangle(cornerRadius: 12))
    }
}

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

                    destructiveButton(
                        title: L10n.Templates.deleteTemplate,
                        action: { viewModel.send(.requestDeleteTemplate) }
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

struct DailyZoneEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyZonesViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let form = viewModel.state.zoneForm {
                        ZoneSheetHeader(
                            iconName: form.editingID == nil ? "plus.square.fill" : "square.and.pencil",
                            title: form.editingID == nil ? L10n.Onboarding.addZoneTitle : L10n.Onboarding.editZone,
                            selectedColor: paletteColor(form.selectedColorIndex),
                            bounceValue: form.selectedColorIndex
                        )

                        AppCard {
                            VStack(alignment: .leading, spacing: 20) {
                                ZoneNameField(
                                    zoneName: Binding(
                                        get: { viewModel.state.zoneForm?.name ?? "" },
                                        set: { viewModel.send(.setZoneName($0)) }
                                    )
                                )
                                ZoneColorPicker(
                                    selectedColorIndex: Binding(
                                        get: { viewModel.state.zoneForm?.selectedColorIndex ?? 0 },
                                        set: { viewModel.send(.setZoneColor($0)) }
                                    )
                                )
                                ZoneTimePickers(
                                    startTime: Binding(
                                        get: { viewModel.state.zoneForm?.startTime ?? Date() },
                                        set: { viewModel.send(.setZoneStart($0)) }
                                    ),
                                    endTime: Binding(
                                        get: { viewModel.state.zoneForm?.endTime ?? Date() },
                                        set: { viewModel.send(.setZoneEnd($0)) }
                                    ),
                                    isHorizontal: form.editingID != nil,
                                    onChange: {}
                                )
                            }
                        }

                        ZoneWarningsView(
                            showOverlapError: form.overlapMessage != nil,
                            showOutsideHoursWarning: form.outsideHoursWarning
                        )
                    }

                    AppButton(
                        title: viewModel.state.zoneForm?.editingID == nil
                            ? L10n.Onboarding.addZone
                            : L10n.Onboarding.saveZone,
                        icon: "checkmark.circle.fill",
                        color: isValid ? AppColors.accentBlue : AppColors.buttonDisabled,
                        foregroundColor: AppColors.onAccent,
                        onTap: { viewModel.send(.submitZoneForm) }
                    )
                    .disabled(!isValid)
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
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

    private var isValid: Bool {
        guard let form = viewModel.state.zoneForm else { return false }
        return form.isValid
    }

    private func paletteColor(_ index: Int) -> Color {
        guard ZoneColorPalette.colors.indices.contains(index) else { return AppColors.runtimeFallback }
        let color = ZoneColorPalette.colors[index]
        return Color(red: color.red, green: color.green, blue: color.blue)
    }
}

@MainActor
private func destructiveButton(title: String, action: @escaping () -> Void) -> some View {
    AppButton(
        title: title,
        icon: "trash.fill",
        color: AppColors.destructive,
        foregroundColor: AppColors.onAccent,
        onTap: action
    )
}
