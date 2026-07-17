import SwiftUI

public struct AppButton: View {
    public enum Size: Sendable {
        case regular
        case compact
    }

    private let title: String
    private let icon: String
    private let color: Color
    private let foregroundColor: Color
    private let size: Size
    private let expandsHorizontally: Bool
    private let onTap: () -> Void

    public init(
        title: String,
        icon: String,
        color: Color,
        foregroundColor: Color = AppColors.onAccent,
        size: Size = .regular,
        expandsHorizontally: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.foregroundColor = foregroundColor
        self.size = size
        self.expandsHorizontally = expandsHorizontally
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Label(title, systemImage: icon)
                .lineLimit(1)
                .frame(maxWidth: expandsHorizontally ? .infinity : nil)
        }
        .buttonStyle(
            PressedDepthButtonStyle(
                color: color,
                foregroundColor: foregroundColor,
                size: size
            )
        )
        .accessibilityLabel(title)
    }
}

private struct PressedDepthButtonStyle: ButtonStyle {
    let color: Color
    let foregroundColor: Color
    let size: AppButton.Size

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.subheadlineHeavy)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, size == .regular ? 16 : 14)
            .padding(.vertical, size == .regular ? 13 : 11)
            .background(
                color.gradient,
                in: RoundedRectangle(
                    cornerRadius: size == .regular ? 16 : 14,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: size == .regular ? 16 : 14,
                    style: .continuous
                )
                .stroke(AppColors.onAccent.opacity(0.22), lineWidth: 1.5)
            }
            .shadow(
                color: color.opacity(0.75),
                radius: 0,
                y: configuration.isPressed ? 2 : size == .regular ? 5 : 4
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

#Preview("AppButton Light") {
    VStack(spacing: 18) {
        AppButton(
            title: "Start quest",
            icon: "star.fill",
            color: AppColors.accentGreen,
            onTap: {}
        )
        AppButton(
            title: "Compact",
            icon: "bolt.fill",
            color: AppColors.accentPurple,
            size: .compact,
            expandsHorizontally: false,
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("AppButton Dark") {
    VStack(spacing: 18) {
        AppButton(
            title: "Start quest",
            icon: "star.fill",
            color: AppColors.accentGreen,
            onTap: {},
        )
        AppButton(
            title: "Compact",
            icon: "bolt.fill",
            color: AppColors.accentPurple,
            size: .compact,
            expandsHorizontally: false,
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
