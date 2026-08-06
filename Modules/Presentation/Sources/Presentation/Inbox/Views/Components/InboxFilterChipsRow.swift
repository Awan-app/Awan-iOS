//
//  InboxFilterChipsRow.swift
//  Presentation
//

import Common
import SwiftUI

struct InboxFilterChipsRow: View {
    @Binding var selectedTaskFilter: InboxTaskFilter
    @Binding var selectedSessionFilter: InboxSessionFilter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(InboxTaskFilter.allCases) { filter in
                        let isSelected = selectedTaskFilter == filter
                        Button {
                            withAnimation(.snappy(duration: 0.2)) {
                                selectedTaskFilter = filter
                            }
                        } label: {
                            Text(title(for: filter))
                                .font(isSelected ? AppFonts.subheadlineHeavy : AppFonts.subheadlineSemibold)
                                .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 9)
                        }
                        .buttonStyle(
                            AppDepthButtonStyle(
                                shape: .roundedRectangle(cornerRadius: 14),
                                surfaceColor: isSelected ? AppColors.accentBlue : AppColors.surface,
                                borderColor: isSelected ? AppColors.accentBlue : AppColors.outline.opacity(0.14),
                                depthColor: isSelected ? AppColors.accentBlueDepth : AppColors.outline.opacity(0.12),
                                borderWidth: 1.5,
                                depthOffset: isSelected ? 3 : 2,
                                pressedOffset: 1
                            )
                        )
                        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom, 4)
            }

            HStack(spacing: 10) {
                Text(L10n.Inbox.sessionsLabel)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: 8) {
                    ForEach(InboxSessionFilter.allCases) { filter in
                        let isSelected = selectedSessionFilter == filter
                        Button {
                            withAnimation(.snappy(duration: 0.2)) {
                                selectedSessionFilter = filter
                            }
                        } label: {
                            Text(title(for: filter))
                                .font(isSelected ? AppFonts.subheadlineHeavy : AppFonts.subheadlineSemibold)
                                .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                        }
                        .buttonStyle(
                            AppDepthButtonStyle(
                                shape: .roundedRectangle(cornerRadius: 14),
                                surfaceColor: isSelected ? AppColors.accentBlue : AppColors.surface,
                                borderColor: isSelected ? AppColors.accentBlue : AppColors.outline.opacity(0.14),
                                depthColor: isSelected ? AppColors.accentBlueDepth : AppColors.outline.opacity(0.12),
                                borderWidth: 1.5,
                                depthOffset: isSelected ? 3 : 2,
                                pressedOffset: 1
                            )
                        )
                        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                    }
                }
            }
        }
    }

    private func title(for filter: InboxTaskFilter) -> String {
        switch filter {
        case .all: return L10n.Inbox.filterAll
        case .drafted: return L10n.Inbox.filterDrafted
        case .active: return L10n.Inbox.filterActive
        case .completed: return L10n.Inbox.filterCompleted
        }
    }

    private func title(for filter: InboxSessionFilter) -> String {
        switch filter {
        case .any: return L10n.Inbox.sessionsAny
        case .activeNow: return L10n.Inbox.sessionsActiveNow
        case .missed: return L10n.Inbox.sessionsMissed
        }
    }
}
