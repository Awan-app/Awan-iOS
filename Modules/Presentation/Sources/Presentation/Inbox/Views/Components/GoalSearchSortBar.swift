//
//  GoalSearchSortBar.swift
//  Presentation
//

import Common
import SwiftUI

public enum GoalSortOption: String, CaseIterable, Identifiable, Sendable {
    case newest
    case oldest
    case nameAZ
    case nameZA
    case deadline

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .newest: return L10n.Goals.sortNewest
        case .oldest: return L10n.Goals.sortOldest
        case .nameAZ: return L10n.Goals.sortNameAZ
        case .nameZA: return L10n.Goals.sortNameZA
        case .deadline: return L10n.Goals.sortDeadline
        }
    }
}

struct GoalSearchSortBar: View {
    @Binding var searchQuery: String
    @Binding var selectedSort: GoalSortOption

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))

                TextField(L10n.Goals.searchPlaceholder, text: $searchQuery)
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

            Menu {
                Picker(L10n.Goals.sortTitle, selection: $selectedSort) {
                    ForEach(GoalSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 46, height: 46)
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .roundedRectangle(cornerRadius: 16),
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.accentBlue.opacity(0.35),
                    depthColor: AppColors.accentBlueDepth.opacity(0.25),
                    borderWidth: 1.5,
                    depthOffset: 4,
                    pressedOffset: 2
                )
            )
            .accessibilityLabel(L10n.Goals.sortTitle)
        }
    }
}

#Preview("Goal Search Sort Bar Light") {
    GoalSearchSortBar(searchQuery: .constant(""), selectedSort: .constant(.newest))
        .padding()
        .background(AppColors.screenBackground)
}

#Preview("Goal Search Sort Bar Dark") {
    GoalSearchSortBar(searchQuery: .constant("Fitness"), selectedSort: .constant(.nameAZ))
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
