import SwiftUI

public struct AppButton: View {
    public enum Size: Sendable {
        case large
        case regular
        case compact
    }

    private let title: String
    private let icon: String?
    private let iconAsset: String?
    private let color: Color
    private let foregroundColor: Color
    private let borderColor: Color?
    private let shadowColor: Color?
    private let size: Size
    private let expandsHorizontally: Bool
    private let onTap: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        iconAsset: String? = nil,
        color: Color,
        foregroundColor: Color = AppColors.onAccent,
        borderColor: Color? = nil,
        shadowColor: Color? = nil,
        size: Size = .regular,
        expandsHorizontally: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.iconAsset = iconAsset
        self.color = color
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.size = size
        self.expandsHorizontally = expandsHorizontally
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Group {
                if let icon {
                    Label(title, systemImage: icon)
                } else if let iconAsset {
                    Label {
                        Text(title)
                    } icon: {
                        Image(iconAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size == .regular ? 20 : 16, height: size == .regular ? 20 : 16)
                    }
                } else {
                    Text(title)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: expandsHorizontally ? .infinity : nil)
        }
        .buttonStyle(
            PressedDepthButtonStyle(
                color: color,
                foregroundColor: foregroundColor,
                borderColor: borderColor,
                shadowColor: shadowColor,
                size: size
            )
        )
        .accessibilityLabel(title)
    }
}

private struct PressedDepthButtonStyle: ButtonStyle {
    let color: Color
    let foregroundColor: Color
    let borderColor: Color?
    let shadowColor: Color?
    let size: AppButton.Size

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.subheadlineHeavy)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, size == .regular ? 16 : 14)
            .padding(.vertical, size == .large ? 18 : size == .regular ? 13 : 11)
            .background(
                color.gradient,
                in: RoundedRectangle(
                    cornerRadius: size == .large ? 18 : size == .regular ? 16 : 14,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: size == .large ? 18 : size == .regular ? 16 : 14,
                    style: .continuous
                )
                .stroke(borderColor ?? AppColors.onAccent.opacity(0.22), lineWidth: 1.5)
            }
            .shadow(
                color: shadowColor ?? color.opacity(0.75),
                radius: 0,
                x: 0,
                y: configuration.isPressed ? 2 : size == .large ? 6 : size == .regular ? 5 : 4
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
