import Lottie
import SwiftUI

public struct StreakFireView: View {
    private let animation: LottieAnimation?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {
        animation = LottieAnimation.named("StreakFire", bundle: .module)
    }

    public var body: some View {
        Group {
            if reduceMotion || animation == nil {
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColors.warning)
                    .padding(8)
            } else {
                LottieView(animation: animation)
                    .looping()
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Streak Fire Light") {
    StreakFireView()
        .frame(width: 80, height: 80)
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.light)
}

#Preview("Streak Fire Dark") {
    StreakFireView()
        .frame(width: 80, height: 80)
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
