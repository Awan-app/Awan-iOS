//
//  ProposedTaskCategoryPicker.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

// MARK: - Category Picker Button

struct ProposedTaskCategoryButton: View {
    let categories: [TaskCategory]
    let zones: [Zone]
    let selectedCategoryID: UUID?
    let onCategoryChanged: (UUID?) -> Void

    @State private var isCategoryPickerPresented = false

    var body: some View {
        Button {
            isCategoryPickerPresented = true
        } label: {
            HStack(spacing: 6) {
                categoryIndicator

                Text(selectedCategoryName)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(
                        selectedCategoryID == nil
                            ? AppColors.textSecondary
                            : AppColors.brandDarkBlue
                    )
                    .lineLimit(1)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                selectedCategoryID == nil
                    ? AppColors.textSecondary.opacity(0.1)
                    : AppColors.infoSurface,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isCategoryPickerPresented, arrowEdge: .bottom) {
            ProposedCategoryPickerPopover(
                categories: categories,
                zones: zones,
                selectedCategoryID: selectedCategoryID,
                onSelect: { categoryID in
                    onCategoryChanged(categoryID)
                    isCategoryPickerPresented = false
                }
            )
            .presentationCompactAdaptation(.popover)
        }
    }

    private var selectedCategoryName: String {
        guard let id = selectedCategoryID else {
            return L10n.Home.proposedTaskUnassigned
        }
        return categories.first(where: { $0.id == id })?.name ?? L10n.Home.proposedTaskUnassigned
    }

    @ViewBuilder
    private var categoryIndicator: some View {
        if let id = selectedCategoryID {
            let colors = zoneColors(for: id)
            ProposedZoneColorSwatches(colors: colors)
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
            else { return nil }
            return zone.color
        }
    }
}

// MARK: - Category Picker Popover

struct ProposedCategoryPickerPopover: View {
    let categories: [TaskCategory]
    let zones: [Zone]
    let selectedCategoryID: UUID?
    let onSelect: (UUID?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            categoryButton(
                title: L10n.Home.proposedTaskUnassigned,
                colors: [],
                isSelected: selectedCategoryID == nil
            ) {
                onSelect(nil)
            }

            Divider()
                .overlay(AppColors.accentBlue.opacity(0.14))

            ForEach(categories) { category in
                categoryButton(
                    title: category.name,
                    colors: zoneColors(for: category.id),
                    isSelected: selectedCategoryID == category.id
                ) {
                    onSelect(category.id)
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
                    ProposedZoneColorSwatches(colors: colors)
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

    private func zoneColors(for categoryID: UUID) -> [ZoneColor] {
        var seen = Set<ZoneColor>()
        return zones.compactMap { zone in
            guard zone.category?.id == categoryID,
                  seen.insert(zone.color).inserted
            else { return nil }
            return zone.color
        }
    }
}

// MARK: - Zone Color Swatches

struct ProposedZoneColorSwatches: View {
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
