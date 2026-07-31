//
//  ProposedTaskCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProposedTaskCard: View {
    let task: ProposedTask
    let categories: [TaskCategory]
    let zones: [Zone]
    let isSelected: Bool
    let onToggleSelect: () -> Void
    let onDurationChanged: (Int) -> Void
    let onCategoryChanged: (UUID?) -> Void

    @State private var isCategoryPickerPresented = false

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header with Checkbox and Title
                HStack(alignment: .top, spacing: 12) {
                    Button(action: onToggleSelect) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(isSelected ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.draft.task.title)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        if let desc = task.draft.task.description, !desc.isEmpty {
                            Text(desc)
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Spacer()
                }

                Divider()

                // Category & Points Row
                HStack(spacing: 8) {
                    // Category picker button
                    Button {
                        isCategoryPickerPresented = true
                    } label: {
                        HStack(spacing: 6) {
                            selectedCategoryIndicator

                            Text(selectedCategoryName)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(
                                    task.draft.task.categoryId == nil
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
                            task.draft.task.categoryId == nil
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
                            selectedCategoryID: task.draft.task.categoryId
                        ) { categoryID in
                            onCategoryChanged(categoryID)
                            isCategoryPickerPresented = false
                        }
                        .presentationCompactAdaptation(.popover)
                    }

                    Spacer()

                    // Points — force LTR so the star never flips in Arabic
                    Label("\(task.draft.task.estimatedPoints) pts", systemImage: "star.fill")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.reward)
                        .environment(\.layoutDirection, .leftToRight)
                }

                // Duration adjustment
                HStack {
                    Text(L10n.Home.duration)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            if task.draft.task.estimatedDuration > 15 {
                                onDurationChanged(task.draft.task.estimatedDuration - 15)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(task.draft.task.estimatedDuration > 15 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.3))
                        }
                        .disabled(task.draft.task.estimatedDuration <= 15)

                        Text(L10n.Home.minutesShort(task.draft.task.estimatedDuration))
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(minWidth: 55)

                        Button {
                            if task.draft.task.estimatedDuration < 480 {
                                onDurationChanged(task.draft.task.estimatedDuration + 15)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(task.draft.task.estimatedDuration < 480 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.3))
                        }
                        .disabled(task.draft.task.estimatedDuration >= 480)
                    }
                }

                // Fixed Sessions (from user source)
                if !task.draft.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "pin.fill")
                                .font(AppFonts.caption2Bold)
                            Text(L10n.Home.proposedTaskFixedSession)
                                .font(AppFonts.caption2Bold)
                        }
                        .foregroundStyle(AppColors.accentPurple)

                        ForEach(task.draft.sessions) { session in
                            HStack {
                                Text("\(Self.timeFormatter.string(from: session.start)) - \(Self.timeFormatter.string(from: session.end))")
                                    .font(AppFonts.captionHeavy)
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColors.accentPurple.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                // AI Proposed Sessions
                if !task.aiProposedSessions.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(AppFonts.caption2Bold)
                            Text(L10n.Home.proposedTaskAiSession)
                                .font(AppFonts.caption2Bold)
                        }
                        .foregroundStyle(AppColors.accentBlue)

                        ForEach(task.aiProposedSessions) { session in
                            HStack {
                                Text("\(Self.timeFormatter.string(from: session.start)) - \(Self.timeFormatter.string(from: session.end))")
                                    .font(AppFonts.captionHeavy)
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColors.accentBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                // AI Reason
                if !task.reason.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(task.reason)
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .opacity(isSelected ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Category helpers

    private var selectedCategoryName: String {
        guard let categoryId = task.draft.task.categoryId else {
            return L10n.Home.proposedTaskUnassigned
        }
        return categories.first(where: { $0.id == categoryId })?.name ?? L10n.Home.proposedTaskUnassigned
    }

    @ViewBuilder
    private var selectedCategoryIndicator: some View {
        if let categoryId = task.draft.task.categoryId {
            let colors = zoneColors(for: categoryId)
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

private struct ProposedCategoryPickerPopover: View {
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

private struct ProposedZoneColorSwatches: View {
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
