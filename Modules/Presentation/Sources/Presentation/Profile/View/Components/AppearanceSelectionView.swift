import SwiftUI
import Common

public struct AppearanceSelectionView: View {
    @Environment(AppearanceManager.self) private var appearanceManager
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.Profile.appearanceTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                VStack(spacing: 0) {
                    ForEach(AppAppearance.allCases, id: \.self) { appearance in
                        appearanceRow(for: appearance)

                        if appearance != AppAppearance.allCases.last {
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
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }

    private func appearanceRow(for appearance: AppAppearance) -> some View {
        let isSelected = appearanceManager.currentAppearance == appearance

        return Button {
            withAnimation {
                appearanceManager.currentAppearance = appearance
                dismiss()
            }
        } label: {
            HStack {
                Text(appearanceName(for: appearance))
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

    private func appearanceName(for appearance: AppAppearance) -> String {
        switch appearance {
        case .light: return L10n.Profile.appearanceLight
        case .dark: return L10n.Profile.appearanceDark
        case .system: return L10n.Profile.appearanceSystem
        }
    }
}

#Preview {
    AppearanceSelectionView()
}
