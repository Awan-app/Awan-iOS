import Common
import SwiftUI

public struct OnboardingContinueButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    public init(title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text(title.uppercased())
                .kerning(1.0)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool

    // Colors
    private var topColor: Color { AppColors.accentBlue }
    private var depthColor: Color { AppColors.accentBlueDepth }
    private var disabledTop: Color { AppColors.buttonDisabled }
    private var disabledDepth: Color { AppColors.buttonDisabledDepth }

    func makeBody(configuration: Configuration) -> some View {
        let depth: CGFloat = 4
        let isPressed = configuration.isPressed
        let pressOffset: CGFloat = isPressed ? depth : 0

        return ZStack(alignment: .top) {
            // Bottom Layer — subtle ledge, always visible
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isEnabled ? depthColor : disabledDepth)
                .frame(height: 56)
                .offset(y: depth)
                .shadow(
                    color: isEnabled ? topColor.opacity(0.18) : .clear,
                    radius: 10, x: 0, y: 6
                )

            // Top Layer — main button face
            configuration.label
                .font(AppFonts.bodyBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isEnabled ? topColor : disabledTop)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .offset(y: pressOffset)
        }
        .frame(height: 56 + depth)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
    }
}

#Preview {
    ZStack {
        AppColors.screenBackground.edgesIgnoringSafeArea(.all)

        VStack(spacing: 32) {
            Spacer()
            
            OnboardingContinueButton(title: "CONTINUE") {
                print("Enabled pressed")
            }

            OnboardingContinueButton(title: "CONTINUE", isEnabled: false) {
                print("Disabled pressed")
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}
