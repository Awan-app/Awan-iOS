//
//  ThemePreferenceRowView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

/// A row with a segmented picker for Theme selection
struct ThemePreferenceRowView: View {
    let icon: String
    let title: String
    @Environment(AppearanceManager.self) private var appearanceManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 26, alignment: .center)

            Text(title)
                .font(AppFonts.subheadlineBold)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            themePicker
        }
    }

    @State private var dragX: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var pickerWidth: CGFloat = 176
    @State private var draggingIndex: Int? = nil

    private var selectedIndex: Int {
        AppAppearance.allCases.firstIndex(of: appearanceManager.currentAppearance) ?? 0
    }

    private var themePicker: some View {
        HStack(spacing: 0) {
            ForEach(AppAppearance.allCases, id: \.self) { theme in
                themeText(for: theme)

                if theme != .dark {
                    Divider()
                        .frame(height: 12)
                }
            }
        }
        .background(alignment: .leading) {
            GeometryReader { geo in
                Color.clear
                    .onAppear { pickerWidth = geo.size.width }
                    .onChange(of: geo.size.width) { _, newWidth in pickerWidth = newWidth }

                let segmentWidth: CGFloat = 58
                let dividerWidth = (geo.size.width - (segmentWidth * 3)) / 2
                let step = segmentWidth + dividerWidth

                let targetOffset = CGFloat(selectedIndex) * step
                let localDragX = dragX - 2
                let currentOffset = isDragging ? min(max(0, localDragX - segmentWidth / 2), geo.size.width - segmentWidth) : targetOffset

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.1))
                    .frame(width: segmentWidth)
                    .offset(x: currentOffset)
                    .animation(isDragging ? .interactiveSpring(response: 0.2, dampingFraction: 0.8) : .snappy(duration: 0.2), value: currentOffset)
            }
        }
        .padding(2)
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColors.outline.opacity(0.15), lineWidth: 1)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    dragX = value.location.x
                    
                    let segmentW = (pickerWidth + 4) / 3
                    let index = Int(max(0, min(2, value.location.x / segmentW)))
                    if draggingIndex != index {
                        withAnimation(.snappy(duration: 0.15)) {
                            draggingIndex = index
                        }
                    }
                }
                .onEnded { value in
                    isDragging = false
                    if let index = draggingIndex {
                        let newTheme = AppAppearance.allCases[index]
                        withAnimation(.snappy(duration: 0.2)) {
                            appearanceManager.currentAppearance = newTheme
                        }
                    }
                    draggingIndex = nil
                }
        )
    }

    private func localizedTitle(for theme: AppAppearance) -> String {
        switch theme {
        case .light: return L10n.Profile.light
        case .dark: return L10n.Profile.dark
        case .system: return L10n.Profile.system
        }
    }

    private func themeText(for theme: AppAppearance) -> some View {
        let isSelected: Bool
        if let draggingIndex = draggingIndex {
            isSelected = AppAppearance.allCases.firstIndex(of: theme) == draggingIndex
        } else {
            isSelected = appearanceManager.currentAppearance == theme
        }

        return Text(localizedTitle(for: theme))
            .font(isSelected ? AppFonts.captionHeavy : AppFonts.subheadlineSemibold)
            .foregroundStyle(isSelected ? AppColors.accentBlue : AppColors.textSecondary)
            .padding(.vertical, 6)
            .frame(width: 58)
            .contentShape(Rectangle())
    }
}
