import Common
import SwiftUI

enum CreationMode: String, CaseIterable, Identifiable {
    case task
    case goal

    var id: Self { self }
}

struct CreationModeSwitcher: View {
    @Binding var selectedMode: CreationMode

    var body: some View {
        HStack(spacing: 6) {
            modeButton(
                title: L10n.Home.addTask,
                icon: "checkmark.circle.fill",
                mode: .task
            )
            modeButton(
                title: L10n.Home.addGoal,
                icon: "target",
                mode: .goal
            )
        }
        .padding(5)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(AppColors.accentBlueDepth.opacity(0.22))
                    .offset(y: 4)

                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(AppColors.surface)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.22), lineWidth: 1.5)
        }
        .padding(.bottom, 4)
        .accessibilityElement(children: .contain)
    }

    private func modeButton(
        title: String,
        icon: String,
        mode: CreationMode
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                selectedMode = mode
            }
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            CreationModeButtonStyle(isSelected: selectedMode == mode)
        )
        .accessibilityAddTraits(
            selectedMode == mode ? .isSelected : []
        )
    }
}

private struct CreationModeButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.subheadlineHeavy)
            .foregroundStyle(
                isSelected ? AppColors.onAccent : AppColors.brandDarkBlue
            )
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColors.accentBlueDepth)
                            .offset(y: configuration.isPressed ? 1 : 4)
                    }

                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(AppColors.accentBlue.gradient)
                                : AnyShapeStyle(AppColors.surface)
                        )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected
                            ? AppColors.onAccent.opacity(0.24)
                            : AppColors.accentBlue.opacity(0.16),
                        lineWidth: 1.5
                    )
            }
            .offset(y: isSelected && configuration.isPressed ? 3 : 0)
            .padding(.bottom, 4)
            .animation(
                .snappy(duration: 0.18),
                value: configuration.isPressed
            )
            .animation(.snappy(duration: 0.18), value: isSelected)
    }
}
