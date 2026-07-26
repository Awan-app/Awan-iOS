import Lottie
import SwiftUI

public enum AwanMascotState: Sendable {
    case normal
    case goal

    fileprivate var animationResource: String {
        switch self {
        case .normal:
            "AwanMascot"
        case .goal:
            "AwanGoalMascot"
        }
    }
}

public struct AwanMascotView: View {
    private let animation: LottieAnimation?

    public init(state: AwanMascotState = .normal) {
        animation = LottieAnimation.named(
            state.animationResource,
            bundle: .module
        )
    }

    public var body: some View {
        LottieView(animation: animation)
            .looping()
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibilityHidden(true)
    }
}

#Preview("Awan Mascot - Normal") {
    AwanMascotView()
        .frame(width: 180, height: 140)
        .padding(32)
        .background(AppColors.screenBackground)
}

#Preview("Awan Mascot - Goal") {
    AwanMascotView(state: .goal)
        .frame(width: 260, height: 180)
        .padding(32)
        .background(AppColors.screenBackground)
}

#Preview("Awan Mascot - Goal Dark") {
    AwanMascotView(state: .goal)
        .frame(width: 260, height: 180)
        .padding(32)
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
