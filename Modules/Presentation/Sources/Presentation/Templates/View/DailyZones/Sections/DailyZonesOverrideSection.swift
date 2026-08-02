import Common
import Domain
import SwiftUI

struct DailyZonesOverrideSection: View {
    let viewModel: DailyZonesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !viewModel.state.overrides.isEmpty {
                overridesStrip
            }
            DailyZonesWeekNavigator(viewModel: viewModel)
            if let templateOverride = viewModel.selectedOverride {
                overrideDetails(templateOverride)
                DailyZonesScheduleSection(viewModel: viewModel, editable: true)
            } else {
                noOverrideCard
                if !viewModel.state.zones.isEmpty {
                    DailyZonesScheduleSection(viewModel: viewModel, editable: false)
                }
            }
        }
    }

    private var overridesStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Templates.dateOverridesTitle)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(orderedOverrides) { templateOverride in
                        DailyZonesOverrideShortcut(
                            templateOverride: templateOverride,
                            isSelected: templateOverride.id == viewModel.selectedOverride?.id,
                            timeZone: viewModel.scheduleTimeZone,
                            onSelect: { date in viewModel.send(.selectDate(date)) }
                        )
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }

    private func overrideDetails(_ templateOverride: TemplateOverride) -> some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            contentInsets: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        ) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "calendar")
                    .font(AppFonts.statSymbol)
                    .foregroundStyle(AppColors.accentPurple)
                    .frame(width: 34, height: 34)
                    .background(
                        AppColors.accentPurple.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Button { viewModel.send(.presentOverrideEditor) } label: {
                            HStack(spacing: 5) {
                                Text(displayName(for: templateOverride))
                                    .lineLimit(1)
                                Image(systemName: "pencil")
                                    .font(AppFonts.caption2IconBlack)
                            }
                            .font(AppFonts.subheadlineBlack)
                            .foregroundStyle(AppColors.textPrimary)
                        }
                        .buttonStyle(.plain)

                        Text(L10n.Templates.oneDayOverride)
                            .font(AppFonts.microHeavy)
                            .foregroundStyle(AppColors.onAccent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppColors.accentPurple, in: Capsule())
                    }

                    Text(L10n.Templates.overrideExplanation)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)

                    Button { viewModel.send(.requestDeleteOverride) } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                            Text(L10n.Templates.useWeeklyRoutine)
                        }
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                        .padding(.vertical, 3)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .confirmationDialog(
            L10n.Templates.useWeeklyRoutineConfirmation,
            isPresented: overrideDeletionDialogBinding,
            titleVisibility: .visible
        ) {
            Button(L10n.Templates.delete, role: .destructive) {
                viewModel.send(.confirmDialog)
            }
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelDialog)
            }
        } message: {
            Text(L10n.Templates.useWeeklyRoutineMessage)
        }
    }

    private var noOverrideCard: some View {
        DailyZonesEmptyCard(
            icon: "calendar.badge.clock",
            title: L10n.Templates.usingWeeklyRoutine,
            message: viewModel.state.zones.isEmpty
                ? L10n.Templates.noWeeklyCoverage
                : L10n.Templates.followsWeeklyRoutine,
            actionTitle: L10n.Templates.createDateOverride,
            compact: true,
            action: {
                viewModel.send(.presentCreation)
                viewModel.send(.setCreationKind(.override))
                viewModel.send(.setCreationDate(viewModel.selectedDateValue))
            }
        )
    }

    private var orderedOverrides: [TemplateOverride] {
        let today = TemplateOverrideDate(date: Date(), timeZone: viewModel.scheduleTimeZone)
        return viewModel.state.overrides.sorted { first, second in
            let firstIsPast = first.dateOfDay < today
            let secondIsPast = second.dateOfDay < today
            if firstIsPast != secondIsPast {
                return !firstIsPast
            }
            return firstIsPast
                ? first.dateOfDay > second.dateOfDay
                : first.dateOfDay < second.dateOfDay
        }
    }

    private var overrideDeletionDialogBinding: Binding<Bool> {
        Binding(
            get: {
                guard case .deleteOverride = viewModel.state.dialog else { return false }
                return true
            },
            set: { if !$0 { viewModel.send(.cancelDialog) } }
        )
    }

    private func displayName(for templateOverride: TemplateOverride) -> String {
        if let name = templateOverride.name, !name.isEmpty {
            return name
        }
        return viewModel.selectedDateValue.formatted(
            .dateTime.weekday(.wide).month(.abbreviated).day()
        )
    }
}
