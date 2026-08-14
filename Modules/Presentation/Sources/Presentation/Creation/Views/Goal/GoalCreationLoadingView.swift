import Common
import SwiftUI

struct GoalCreationLoadingView: View {
    let message: String
    let mascotState: AwanMascotState
    let mascotSize: CGSize

    init(
        message: String,
        mascotState: AwanMascotState = .normal,
        mascotSize: CGSize = CGSize(width: 230, height: 190)
    ) {
        self.message = message
        self.mascotState = mascotState
        self.mascotSize = mascotSize
    }

    var body: some View {
        ZStack {
            AppCloudsHorizon(height: 230)
                .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                AwanMascotView(state: mascotState)
                    .frame(width: mascotSize.width, height: mascotSize.height)

                AppDepthSurface(
                    shape: .roundedRectangle(cornerRadius: 18),
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.accentBlue.opacity(0.24),
                    depthColor: AppColors.accentBlueDepth.opacity(0.5),
                    borderWidth: 1.5,
                    depthOffset: 5,
                    contentInsets: EdgeInsets(
                        top: 16,
                        leading: 20,
                        bottom: 16,
                        trailing: 20
                    )
                ) {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(AppColors.accentBlue)
                            .controlSize(.regular)

                        Text(message)
                            .font(AppFonts.title3Black)
                            .foregroundStyle(AppColors.brandDarkBlue)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    GoalCreationLoadingView(
        message: "Building your goal plan...",
        mascotState: .goal
    )
    .background(AppColors.screenBackground)
}
