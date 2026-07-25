import Common
import SwiftUI

struct GoalCreationLoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 30)

            AwanMascotView()
                .frame(width: 190, height: 150)

            VStack(spacing: 9) {
                Text(message)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .multilineTextAlignment(.center)

                ProgressView()
                    .tint(AppColors.accentBlue)
                    .controlSize(.regular)
            }

            Spacer(minLength: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}
#Preview{
    GoalCreationLoadingView(message: "")
}


#Preview {
    GoalCreationLoadingView(message: "Loading...")
}

