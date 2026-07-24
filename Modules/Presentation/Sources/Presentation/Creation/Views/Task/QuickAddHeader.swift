import Common
import SwiftUI

struct QuickAddHeader: View {
    let isAwanSchedulingEnabled: Bool

    @State private var isMascotFloating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(header.uppercased())
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(headline)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(caption)
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
                            .easeInOut(duration: 2).repeatForever(autoreverses: true)
                        ) {
                            isMascotFloating = true
                        }
                    }
            }
        }
        .animation(
            .easeInOut(duration: 0.2),
            value: isAwanSchedulingEnabled
        )
    }

    private var header: String {
        isAwanSchedulingEnabled
            ? L10n.Home.quickAddHeader
            : L10n.Home.manualAddHeader
    }

    private var headline: String {
        isAwanSchedulingEnabled
            ? L10n.Home.quickAddHeadline
            : L10n.Home.manualAddHeadline
    }

    private var caption: String {
        isAwanSchedulingEnabled
            ? L10n.Home.quickAddCaption
            : L10n.Home.manualAddCaption
    }
}
