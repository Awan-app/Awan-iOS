import Common
import Domain
import SwiftUI

struct DailyWheelResultOverlay: View {
    let result: DailyWheelResultPresentation
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            AppColors.shadow
                .opacity(0.84)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                rewardArtwork

                VStack(spacing: 10) {
                    Text(title)
                        .font(AppFonts.titleBlack)
                        .foregroundStyle(AppColors.onAccent)
                        .multilineTextAlignment(.center)

                    Text(rewardText)
                        .font(AppFonts.title2Black)
                        .foregroundStyle(AppColors.reward)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.accentBlue)
                        .multilineTextAlignment(.center)
                }

                AppButton(
                    title: dismissButtonTitle,
                    icon: "checkmark",
                    color: AppColors.accentBlue,
                    onTap: onDismiss
                )
                .frame(maxWidth: 230)
            }
            .padding(.horizontal, 28)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: Text(L10n.DailyWheel.dismiss)) {
            onDismiss()
        }
    }

    @ViewBuilder
    private var rewardArtwork: some View {
        switch result {
        case let .spin(spin) where spin.payoutType == .item:
            if let url = spin.item?.imageURL {
                AppRemoteImage(url: url) {
                    giftArtwork
                }
                .frame(width: 180, height: 180)
                .background(AppColors.surface.opacity(0.14), in: Circle())
            } else {
                giftArtwork
            }
        default:
            ZStack {
                Circle()
                    .fill(AppColors.reward.opacity(0.18))
                    .frame(width: 180, height: 180)
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 116, weight: .black))
                    .foregroundStyle(AppColors.reward)
            }
        }
    }

    private var giftArtwork: some View {
        ZStack {
            Circle()
                .fill(AppColors.accentPurple.opacity(0.22))
                .frame(width: 180, height: 180)
            Image(systemName: "gift.fill")
                .font(.system(size: 102, weight: .black))
                .foregroundStyle(AppColors.accentPurple)
        }
    }

    private var title: String {
        L10n.DailyWheel.youWon
    }

    private var dismissButtonTitle: String {
        L10n.DailyWheel.awesome
    }

    private var rewardText: String {
        switch result {
        case let .spin(spin):
            if spin.payoutType == .item {
                return spin.item?.name ?? L10n.DailyWheel.gift
            }
            return L10n.DailyWheel.starsAwarded(spin.coinsAwarded)
        }
    }

    private var subtitle: String {
        switch result {
        case let .spin(spin):
            if spin.payoutType == .coins {
                return L10n.DailyWheel.newBalance(spin.newBalance)
            }
            return L10n.DailyWheel.itemAdded
        }
    }
}

#Preview("Wheel Coin Result Light") {
    DailyWheelResultOverlay(
        result: .spin(
            DailyWheelSpinResult(
                segmentID: "SEG_5",
                payoutType: .coins,
                coinsAwarded: 50,
                newBalance: 230,
                item: nil
            )
        ),
        onDismiss: {}
    )
}

#Preview("Wheel Item Result RTL Dark") {
    DailyWheelResultOverlay(
        result: .spin(
            DailyWheelSpinResult(
                segmentID: "SEG_ITEM",
                payoutType: .item,
                coinsAwarded: 0,
                newBalance: 180,
                item: GamificationRewardItem(
                    id: "gift-id",
                    name: "Aurora Frame",
                    description: nil,
                    imageURL: nil,
                    info: nil,
                    price: 200,
                    version: "1.0",
                    type: "FRAME"
                )
            )
        ),
        onDismiss: {}
    )
    .environment(\.layoutDirection, .rightToLeft)
    .preferredColorScheme(.dark)
}
