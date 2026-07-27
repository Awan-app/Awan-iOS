import SwiftUI

public enum AppDepthShape: Sendable {
    case capsule
    case circle
    case roundedRectangle(cornerRadius: CGFloat)

    fileprivate var shape: AnyShape {
        switch self {
        case .capsule:
            AnyShape(Capsule())
        case .circle:
            AnyShape(Circle())
        case let .roundedRectangle(cornerRadius):
            AnyShape(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
        }
    }
}

public struct AppDepthSurface<Content: View>: View {
    private let shape: AppDepthShape
    private let surfaceColor: Color
    private let borderColor: Color
    private let depthColor: Color
    private let borderWidth: CGFloat
    private let depthOffset: CGFloat
    private let contentInsets: EdgeInsets
    private let content: Content

    public init(
        shape: AppDepthShape = .roundedRectangle(cornerRadius: 24),
        surfaceColor: Color = AppColors.surface,
        borderColor: Color = AppColors.outline.opacity(0.10),
        depthColor: Color = AppColors.outline.opacity(0.16),
        borderWidth: CGFloat = 1.5,
        depthOffset: CGFloat = 5,
        contentInsets: EdgeInsets = EdgeInsets(
            top: 18,
            leading: 18,
            bottom: 18,
            trailing: 18
        ),
        @ViewBuilder content: () -> Content
    ) {
        self.shape = shape
        self.surfaceColor = surfaceColor
        self.borderColor = borderColor
        self.depthColor = depthColor
        self.borderWidth = borderWidth
        self.depthOffset = depthOffset
        self.contentInsets = contentInsets
        self.content = content()
    }

    public var body: some View {
        content
            .padding(contentInsets)
            .background {
                ZStack {
                    shape.shape
                        .fill(depthColor)
                        .offset(y: depthOffset)

                    shape.shape
                        .fill(surfaceColor)
                }
            }
            .overlay {
                shape.shape
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .padding(.bottom, depthOffset)
    }
}

public struct AppDepthButtonStyle: ButtonStyle {
    private let shape: AppDepthShape
    private let surfaceColor: Color
    private let borderColor: Color
    private let depthColor: Color
    private let borderWidth: CGFloat
    private let depthOffset: CGFloat
    private let pressedOffset: CGFloat

    public init(
        shape: AppDepthShape = .circle,
        surfaceColor: Color = AppColors.surface,
        borderColor: Color = AppColors.accentBlue.opacity(0.45),
        depthColor: Color = AppColors.accentBlueDepth,
        borderWidth: CGFloat = 1.5,
        depthOffset: CGFloat = 4,
        pressedOffset: CGFloat = 3
    ) {
        self.shape = shape
        self.surfaceColor = surfaceColor
        self.borderColor = borderColor
        self.depthColor = depthColor
        self.borderWidth = borderWidth
        self.depthOffset = depthOffset
        self.pressedOffset = pressedOffset
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .hidden()

            configuration.label
                .background(surfaceColor, in: shape.shape)
                .overlay {
                    shape.shape
                        .stroke(borderColor, lineWidth: borderWidth)
                }
                .offset(y: configuration.isPressed ? pressedOffset : 0)
        }
        .background {
            shape.shape
                .fill(depthColor)
                .offset(y: depthOffset)
        }
        .padding(.bottom, depthOffset)
        .contentShape(shape.shape)
        .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

#Preview("App Depth Styles Light") {
    VStack(spacing: 20) {
        AppDepthSurface {
            Text("Raised card")
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
        }

        Button {} label: {
            Label("Present", systemImage: "arrow.uturn.backward")
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.accentBlue)
                .padding(.horizontal, 14)
                .frame(height: 40)
        }
        .buttonStyle(AppDepthButtonStyle(shape: .capsule))
    }
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("App Depth Styles Dark") {
    VStack(spacing: 20) {
        AppDepthSurface {
            Text("Raised card")
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
        }

        Button {} label: {
            Image(systemName: "calendar")
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(AppDepthButtonStyle())
    }
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
