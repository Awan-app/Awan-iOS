import SwiftUI

public struct AppCloudsHorizon: View {
    @Environment(\.colorScheme) private var colorScheme

    private let height: CGFloat

    private var contourOpacity: Double {
        colorScheme == .dark ? 0.3 : 0.5
    }

    private var volumeOpacity: Double {
        colorScheme == .dark ? 0.24 : 0.38
    }

    private var foregroundContourOpacity: Double {
        colorScheme == .dark ? 0.2 : 0.36
    }

    public init(height: CGFloat = 150) {
        self.height = height
    }

    public var body: some View {
        Canvas { context, size in
            drawLobes(in: &context, size: size)
            drawForegroundPuffs(in: &context, size: size)
        }
        .frame(height: height)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: AppColors.cloudSurface.opacity(0.18), location: 0),
                    .init(color: AppColors.cloudSurface.opacity(0.9), location: 0.14),
                    .init(color: AppColors.cloudSurface, location: 0.32),
                    .init(color: AppColors.cloudSurface, location: 0.78),
                    .init(color: AppColors.cloudSurface.opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawLobes(
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        let spacing = max(size.height * 0.58, 82)
        let lobeCount = Int(ceil(size.width / spacing)) + 2
        let diameterScales: [CGFloat] = [1.02, 1.12, 0.96, 1.08, 1]
        let verticalScales: [CGFloat] = [0.54, 0.47, 0.58, 0.49, 0.55]

        for index in -1..<lobeCount {
            let patternIndex = (index + diameterScales.count) % diameterScales.count
            let diameter = size.height * diameterScales[patternIndex]
            let center = CGPoint(
                x: CGFloat(index) * spacing + spacing * 0.55,
                y: size.height * verticalScales[patternIndex]
            )
            let frontRect = CGRect(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2,
                width: diameter,
                height: diameter
            )
            let depthRect = frontRect.offsetBy(
                dx: diameter * 0.13,
                dy: diameter * 0.08
            )

            context.fill(
                Path(ellipseIn: depthRect),
                with: .radialGradient(
                    Gradient(colors: [
                        AppColors.cloudSurface.opacity(0.78),
                        AppColors.cloudDepth.opacity(0.94)
                    ]),
                    center: CGPoint(
                        x: depthRect.minX + diameter * 0.3,
                        y: depthRect.minY + diameter * 0.25
                    ),
                    startRadius: 0,
                    endRadius: diameter * 0.72
                )
            )

            context.fill(
                Path(ellipseIn: frontRect),
                with: .radialGradient(
                    Gradient(colors: [
                        AppColors.cloudHighlight,
                        AppColors.cloudSurface.opacity(0.98),
                        AppColors.cloudDepth.opacity(contourOpacity)
                    ]),
                    center: CGPoint(
                        x: frontRect.minX + diameter * 0.35,
                        y: frontRect.minY + diameter * 0.3
                    ),
                    startRadius: 0,
                    endRadius: diameter * 0.62
                )
            )

            drawVolume(
                in: &context,
                cloudRect: frontRect
            )
        }
    }

    private func drawVolume(
        in context: inout GraphicsContext,
        cloudRect: CGRect
    ) {
        context.drawLayer { layer in
            layer.clip(to: Path(ellipseIn: cloudRect))

            layer.fill(
                Path(ellipseIn: cloudRect),
                with: .radialGradient(
                    Gradient(colors: [
                        AppColors.cloudSurface.opacity(0),
                        AppColors.cloudSurface.opacity(0.08),
                        AppColors.cloudDepth.opacity(volumeOpacity)
                    ]),
                    center: CGPoint(
                        x: cloudRect.minX + cloudRect.width * 0.3,
                        y: cloudRect.minY + cloudRect.height * 0.24
                    ),
                    startRadius: cloudRect.width * 0.08,
                    endRadius: cloudRect.width * 0.7
                )
            )

            let highlightRect = CGRect(
                x: cloudRect.minX + cloudRect.width * 0.14,
                y: cloudRect.minY + cloudRect.height * 0.12,
                width: cloudRect.width * 0.48,
                height: cloudRect.height * 0.34
            )
            layer.fill(
                Path(ellipseIn: highlightRect),
                with: .radialGradient(
                    Gradient(colors: [
                        AppColors.cloudHighlight.opacity(0.5),
                        AppColors.cloudHighlight.opacity(0)
                    ]),
                    center: CGPoint(x: highlightRect.midX, y: highlightRect.midY),
                    startRadius: 0,
                    endRadius: highlightRect.width * 0.52
                )
            )
        }
    }

    private func drawForegroundPuffs(
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        let diameter = size.height * 0.68
        let spacing = diameter * 0.78
        let count = Int(ceil(size.width / spacing)) + 2

        for index in -1..<count {
            let center = CGPoint(
                x: CGFloat(index) * spacing + spacing * 0.45,
                y: size.height * (index.isMultiple(of: 2) ? 0.82 : 0.88)
            )
            let rect = CGRect(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2,
                width: diameter,
                height: diameter
            )

            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(
                    Gradient(colors: [
                        AppColors.cloudHighlight,
                        AppColors.cloudSurface.opacity(0.98),
                        AppColors.cloudDepth.opacity(foregroundContourOpacity)
                    ]),
                    center: CGPoint(
                        x: rect.minX + diameter * 0.34,
                        y: rect.minY + diameter * 0.28
                    ),
                    startRadius: 0,
                    endRadius: diameter * 0.65
                )
            )
        }
    }
}

#Preview("Cloud Horizon — Light") {
    ZStack(alignment: .top) {
        AppColors.screenBackground.ignoresSafeArea()
        AppCloudsHorizon(height: 180)
    }
    .preferredColorScheme(.light)
}

#Preview("Cloud Horizon — Dark") {
    ZStack(alignment: .top) {
        AppColors.screenBackground.ignoresSafeArea()
        AppCloudsHorizon(height: 180)
    }
    .preferredColorScheme(.dark)
}
