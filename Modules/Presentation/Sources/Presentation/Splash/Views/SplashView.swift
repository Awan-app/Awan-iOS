import SwiftUI
import Common

struct SplashView: View {
    private static let cloudBandHeight: CGFloat = 180
    private static let wordmarkDelay: Duration = .milliseconds(220)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var mascotIsVisible = false
    @State private var wordmarkIsVisible = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                LinearGradient(
                    stops: [
                        .init(color: AppColors.splashSkyMidday, location: 0),
                        .init(
                            color: AppColors.splashBackgroundStart,
                            location: bandTop(for: proxy.size.height)
                        ),
                        .init(color: AppColors.splashBackgroundStart, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                SplashCloudDrift()

                VStack(spacing: 24) {
                    AwanMascotView(state: .normal)
                        .frame(width: 176, height: 137)
                        .scaleEffect(mascotIsVisible ? 1 : 0.6)
                        .opacity(mascotIsVisible ? 1 : 0)

                    Text(verbatim: "Awan")
                        .font(AppFonts.splashDisplay)
                        .foregroundStyle(AppColors.splashText)
                        .opacity(wordmarkIsVisible ? 1 : 0)
                        .offset(y: wordmarkIsVisible ? 0 : 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea()
        .task {
            guard !reduceMotion else {
                mascotIsVisible = true
                wordmarkIsVisible = true
                return
            }

            withAnimation(.spring(response: 0.7, dampingFraction: 0.55)) {
                mascotIsVisible = true
            }

            try? await Task.sleep(for: Self.wordmarkDelay)
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                wordmarkIsVisible = true
            }
        }
    }

    private func bandTop(for height: CGFloat) -> CGFloat {
        guard height > 0 else { return 1 }
        return max(0, min(1, 1 - Self.cloudBandHeight / height))
    }
}

#Preview("Splash — Light") {
    SplashView()
        .preferredColorScheme(.light)
}

#Preview("Splash — Dark") {
    SplashView()
        .preferredColorScheme(.dark)
}
