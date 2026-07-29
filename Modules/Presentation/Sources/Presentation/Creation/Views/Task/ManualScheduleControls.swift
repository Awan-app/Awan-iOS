import Common
import Domain
import SwiftUI

struct ManualScheduleControls: View {
    let categories: [TaskCategory]
    let zones: [Zone]

    @Binding var startsAt: Date
    @Binding var durationMinutes: Int
    @Binding var selectedCategoryID: UUID?
    @State private var isCategoryPickerPresented = false

    var body: some View {
        VStack(spacing: 0) {
            controlRow(
                icon: "clock.fill",
                title: L10n.Home.fieldStartsAt
            ) {
                DatePicker(
                    "",
                    selection: $startsAt,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .tint(AppColors.accentBlue)
            }

            Divider()
                .overlay(AppColors.accentBlue.opacity(0.14))
                .padding(.leading, 46)

            controlRow(
                icon: "hourglass",
                title: L10n.Home.estimatedDuration
            ) {
                HStack(spacing: 10) {
                    stepButton(icon: "minus") {
                        durationMinutes = max(15, durationMinutes - 15)
                    }

                    Text(durationText)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .monospacedDigit()
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)

                    stepButton(icon: "plus") {
                        durationMinutes = min(480, durationMinutes + 15)
                    }
                }
            }

            if !categories.isEmpty {
                Divider()
                    .overlay(AppColors.accentBlue.opacity(0.14))
                    .padding(.leading, 46)

                controlRow(
                    icon: "square.grid.2x2.fill",
                    title: L10n.Schedule.category
                ) {
                    Button {
                        isCategoryPickerPresented = true
                    } label: {
                        HStack(spacing: 7) {
                            selectedCategoryIndicator

                            Text(selectedCategoryName)
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.brandDarkBlue)
                                .lineLimit(1)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $isCategoryPickerPresented, arrowEdge: .bottom) {
                        CategoryPickerPopover(
                            options: categoryOptions,
                            selectedCategoryID: selectedCategoryID
                        ) { categoryID in
                            selectedCategoryID = categoryID
                            isCategoryPickerPresented = false
                        }
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.accentBlueDepth.opacity(0.45))
                    .offset(y: 5)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.surface)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1.5)
        }
        .padding(.bottom, 5)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func controlRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 34, height: 34)
                .background(AppColors.infoSurface, in: Circle())

            Text(title)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.brandDarkBlue)

            Spacer(minLength: 8)

            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func stepButton(
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 28, height: 28)
                .background(AppColors.infoSurface, in: Circle())
                .overlay {
                    Circle()
                        .stroke(AppColors.accentBlue.opacity(0.24), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var durationText: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let minutes = durationMinutes % 60
            return minutes == 0
                ? L10n.Home.hoursShort(hours)
                : L10n.Home.hoursMinutesShort(hours, minutes)
        }
        return L10n.Home.minutesShort(durationMinutes)
    }

    private var selectedCategoryName: String {
        guard let selectedCategoryID else {
            return L10n.Schedule.standalone
        }
        return categories
            .first(where: { $0.id == selectedCategoryID })?
            .name
            ?? L10n.Schedule.chooseCategory
    }

    private var categoryOptions: [ManualCategoryOption] {
        categories.map {
            ManualCategoryOption(
                category: $0,
                colors: zoneColors(for: $0.id)
            )
        }
    }

    @ViewBuilder
    private var selectedCategoryIndicator: some View {
        if let selectedCategoryID {
            ZoneColorSwatches(colors: zoneColors(for: selectedCategoryID))
        } else {
            Circle()
                .fill(AppColors.runtimeFallback)
                .frame(width: 10, height: 10)
        }
    }

    private func zoneColors(for categoryID: UUID) -> [ZoneColor] {
        var seen = Set<ZoneColor>()
        return zones.compactMap { zone in
            guard zone.category?.id == categoryID,
                  seen.insert(zone.color).inserted
            else {
                return nil
            }
            return zone.color
        }
    }
}

private struct ManualCategoryOption: Identifiable {
    let category: TaskCategory
    let colors: [ZoneColor]

    var id: UUID { category.id }
}

private struct CategoryPickerPopover: View {
    let options: [ManualCategoryOption]
    let selectedCategoryID: UUID?
    let onSelect: (UUID?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            categoryButton(
                title: L10n.Schedule.standalone,
                colors: [],
                isSelected: selectedCategoryID == nil
            ) {
                onSelect(nil)
            }

            Divider()
                .overlay(AppColors.accentBlue.opacity(0.14))

            ForEach(options) { option in
                categoryButton(
                    title: option.category.name,
                    colors: option.colors,
                    isSelected: selectedCategoryID == option.id
                ) {
                    onSelect(option.id)
                }
            }
        }
        .padding(10)
        .frame(minWidth: 220)
        .background(AppColors.surface)
    }

    private func categoryButton(
        title: String,
        colors: [ZoneColor],
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if colors.isEmpty {
                    Circle()
                        .fill(AppColors.runtimeFallback)
                        .frame(width: 10, height: 10)
                } else {
                    ZoneColorSwatches(colors: colors)
                }

                Text(title)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .lineLimit(1)

                Spacer(minLength: 12)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(
                isSelected ? AppColors.infoSurface : Color.clear,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ZoneColorSwatches: View {
    let colors: [ZoneColor]

    var body: some View {
        HStack(spacing: 3) {
            if colors.isEmpty {
                Circle()
                    .fill(AppColors.accentBlue)
                    .frame(width: 10, height: 10)
            } else {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(AppColors.runtime(hex: color.hex))
                        .frame(width: 10, height: 10)
                }
            }
        }
    }
}

#Preview {
    ManualScheduleControls(
        categories: [],
        zones: [],
        startsAt: .constant(Date()),
        durationMinutes: .constant(60),
        selectedCategoryID: .constant(nil)
    )
        .padding()
}
