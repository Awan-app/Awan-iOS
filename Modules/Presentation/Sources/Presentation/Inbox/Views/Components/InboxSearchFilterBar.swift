//
//  InboxSearchFilterBar.swift
//  Presentation
//

import Common
import SwiftUI

struct InboxSearchFilterBar: View {
    @Binding var searchQuery: String
    @Binding var isFilterExpanded: Bool
    let hasActiveFilters: Bool
    let showsFilterButton: Bool
    var placeholder = L10n.Inbox.searchPlaceholder

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))

                TextField(placeholder, text: $searchQuery)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .autocorrectionDisabled()

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.outline.opacity(0.12), lineWidth: 1.5)
            )

            if showsFilterButton {
                Button {
                    withAnimation(.snappy(duration: 0.24)) {
                        isFilterExpanded.toggle()
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(
                                isFilterExpanded ? AppColors.onAccent : AppColors.accentBlue
                            )
                            .frame(width: 46, height: 46)

                        if hasActiveFilters && !isFilterExpanded {
                            Circle()
                                .fill(AppColors.accentBlue)
                                .frame(width: 8, height: 8)
                                .overlay {
                                    Circle()
                                        .stroke(AppColors.surface, lineWidth: 2)
                                }
                                .offset(x: -3, y: 3)
                        }
                    }
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        shape: .roundedRectangle(cornerRadius: 16),
                        surfaceColor: isFilterExpanded ? AppColors.accentBlue : AppColors.surface,
                        borderColor: AppColors.accentBlue.opacity(0.35),
                        depthColor: isFilterExpanded
                            ? AppColors.accentBlueDepth
                            : AppColors.accentBlueDepth.opacity(0.25),
                        borderWidth: 1.5,
                        depthOffset: 4,
                        pressedOffset: 2
                    )
                )
                .accessibilityLabel(
                    isFilterExpanded ? L10n.Inbox.hideFilters : L10n.Inbox.showFilters
                )
                .accessibilityValue(
                    hasActiveFilters ? L10n.Inbox.filtersApplied : L10n.Inbox.noFiltersApplied
                )
            }
        }
    }
}

#Preview("Inbox Search Filter Bar Light") {
    InboxSearchFilterBar(
        searchQuery: .constant(""),
        isFilterExpanded: .constant(false),
        hasActiveFilters: false,
        showsFilterButton: true
    )
        .padding()
        .background(AppColors.screenBackground)
}

#Preview("Inbox Search Filter Bar Dark") {
    InboxSearchFilterBar(
        searchQuery: .constant("presentation"),
        isFilterExpanded: .constant(true),
        hasActiveFilters: true,
        showsFilterButton: true
    )
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
