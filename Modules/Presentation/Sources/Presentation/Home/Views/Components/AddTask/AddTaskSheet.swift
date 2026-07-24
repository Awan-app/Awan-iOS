import Common
import Domain
import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    let zones: [Zone]
    let selectedDay: Date
    let onSubmit: (
        _ title: String,
        _ description: String?,
        _ durationMinutes: Int,
        _ zoneID: UUID?,
        _ isSplittable: Bool,
        _ mandatory: Bool,
        _ startsAt: Date
    ) -> Void

    @State private var selectedTab: TabSwitcher.Tab = .quickAdd
    @State private var quickText: String = ""
    @State private var useSmartDuration: Bool = true
    @State private var useBestZone: Bool = true
    @State private var useAutoSchedule: Bool = true
    @State private var manualTitle: String = ""
    @State private var manualDescription: String = ""
    @State private var manualDurationMinutes: Int = 120
    @State private var selectedZoneID: UUID?
    @State private var isMandatory: Bool = true
    @State private var allowTaskSplitting: Bool = true

    init(
        zones: [Zone],
        selectedDay: Date,
        onSubmit: @escaping (String, String?, Int, UUID?, Bool, Bool, Date) -> Void
    ) {
        self.zones = zones
        self.selectedDay = selectedDay
        self.onSubmit = onSubmit
        _selectedZoneID = State(initialValue: zones.first?.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            TabSwitcher(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            ScrollView(showsIndicators: false) {
                Group {
                    switch selectedTab {
                    case .quickAdd:
                        QuickAddTab(
                            zones: zones,
                            onSubmit: handleQuickAdd,
                            quickText: $quickText,
                            useSmartDuration: $useSmartDuration,
                            useBestZone: $useBestZone,
                            useAutoSchedule: $useAutoSchedule
                        )
                    case .manual:
                        ManualTab(
                            zones: zones,
                            selectedDay: selectedDay,
                            onSubmit: handleManualAdd,
                            title: $manualTitle,
                            description: $manualDescription,
                            durationMinutes: $manualDurationMinutes,
                            selectedZoneID: $selectedZoneID,
                            isMandatory: $isMandatory,
                            allowTaskSplitting: $allowTaskSplitting
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var headerView: some View {
        HStack {
            Text(L10n.Home.addTaskTitle)
                .font(AppFonts.title2Black)
                .foregroundStyle(AppColors.brandDarkBlue)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(
                                color: AppColors.brandDarkBlue.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        Circle()
                            .stroke(AppColors.brandDarkBlue.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func handleQuickAdd(title: String, duration: Int, zoneID: UUID?, autoSchedule: Bool) {
        let now = Date()
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let startsAt = calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: selectedDay
        ) ?? selectedDay
        onSubmit(title, nil, duration, zoneID, true, true, startsAt)
        dismiss()
    }

    private func handleManualAdd(
        title: String,
        description: String?,
        duration: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        mandatory: Bool,
        startsAt: Date
    ) {
        onSubmit(title, description, duration, zoneID, isSplittable, mandatory, startsAt)
        dismiss()
    }
}
