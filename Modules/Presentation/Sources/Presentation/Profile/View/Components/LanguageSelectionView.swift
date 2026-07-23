//
//  LanguageSelectionView.swift
//  Presentation
//
//  Created by AI on 2026.
//

import SwiftUI
import Common

public struct LanguageSelectionView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.Profile.languageSelectionTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                VStack(spacing: 0) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        languageRow(for: language)

                        if language != AppLanguage.allCases.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(AppColors.skyGradient)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
    }

    private func languageRow(for language: AppLanguage) -> some View {
        let isSelected = languageManager.currentLanguage == language

        return Button {
            withAnimation {
                languageManager.currentLanguage = language
                // The LanguageManager will save to UserDefaults. We don't forcefully reload here,
                // SwiftUI will react if LanguageManager is observed, though typically an app restart
                // or scene rebuild is needed for some deep changes. We just dismiss.
                dismiss()
            }
        } label: {
            HStack {
                Text(languageName(for: language))
                    .font(isSelected ? AppFonts.bodySemibold : AppFonts.bodySemibold)
                    .foregroundStyle(isSelected ? AppColors.accentBlue : AppColors.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func languageName(for language: AppLanguage) -> String {
        switch language {
        case .english: return L10n.Profile.languageEnglish
        case .arabic: return L10n.Profile.languageArabic
        }
    }
}

#Preview {
    LanguageSelectionView()
}
