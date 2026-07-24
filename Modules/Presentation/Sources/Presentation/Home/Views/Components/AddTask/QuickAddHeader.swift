import Common
import SwiftUI

struct QuickAddHeader: View {
    @State private var isMascotFloating: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Home.quickAddHeader.uppercased())
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Home.quickAddHeadline)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.Home.quickAddCaption)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 2)

                Image("info-cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 105, height: 105)
                    .layoutPriority(1)
                    .offset(y: isMascotFloating ? -6 : 6)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                        ) {
                            isMascotFloating = true
                        }
                    }
            }
        }
    }
}
