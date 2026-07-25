import Lottie
import SwiftUI

public struct AwanMascotView: View {
    private let animation = LottieAnimation.named(
        "AwanMascot",
        bundle: .module
    )

    public init() {}

    public var body: some View {
        LottieView(animation: animation)
            .looping()
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibilityHidden(true)
    }
}

#Preview("Awan Mascot - Light") {
    AwanMascotView()
}

#Preview("Awan Mascot - Dark") {
    AwanMascotView()
        .frame(width: 120, height: 120)
        .padding(32)
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
