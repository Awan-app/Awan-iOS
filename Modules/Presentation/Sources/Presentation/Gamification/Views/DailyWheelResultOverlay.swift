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
                AsyncImage(url: url) { phase in
                    if case let .success(image) = phase {
                        image.resizable().scaledToFit()
                    } else {
                        giftArtwork
                    }
                }
                .frame(width: 180, height: 180)
                .background(AppColors.surface.opacity(0.14), in: Circle())
            } else {
                giftArtwork
            }
        case let .previousClaim(claim)
            where claim?.itemID != nil || claim?.itemName != nil:
            giftArtwork
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
        switch result {
        case .spin:
            L10n.DailyWheel.youWon
        case .previousClaim:
            L10n.DailyWheel.alreadyClaimed
        }
    }

    private var dismissButtonTitle: String {
        switch result {
        case .spin: L10n.DailyWheel.awesome
        case .previousClaim: L10n.Common.gotIt
        }
    }

    private var rewardText: String {
        switch result {
        case let .spin(spin):
            if spin.payoutType == .item {
                return spin.item?.name ?? L10n.DailyWheel.gift
            }
            return L10n.DailyWheel.starsAwarded(spin.coinsAwarded)
        case let .previousClaim(claim):
            guard let claim else { return L10n.DailyWheel.giftClaimed }
            if let itemName = claim.itemName {
                return itemName
            }
            if claim.itemID != nil {
                return L10n.DailyWheel.gift
            }
            return L10n.DailyWheel.starsAwarded(claim.coinsAwarded)
        }
    }

    private var subtitle: String {
        switch result {
        case let .spin(spin):
            if spin.payoutType == .coins {
                return L10n.DailyWheel.newBalance(spin.newBalance)
            }
            return L10n.DailyWheel.itemAdded
        case .previousClaim:
            return L10n.DailyWheel.comeBackTomorrow
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

#Preview("Wheel Claimed RTL Dark") {
    DailyWheelResultOverlay(
        result: .previousClaim(
            DailyWheelClaim(
                segmentID: "SEG_ITEM",
                coinsAwarded: 0,
                itemID: "gift-id",
                itemName: "Aurora Frame",
                claimDate: "2026-08-09",
                claimedAt: "2026-08-09T10:00:00Z"
            )
        ),
        onDismiss: {}
    )
    .environment(\.layoutDirection, .rightToLeft)
    .preferredColorScheme(.dark)
}
