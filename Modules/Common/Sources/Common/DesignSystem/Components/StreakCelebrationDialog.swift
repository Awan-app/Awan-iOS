import Lottie
import SwiftUI

public struct StreakCelebrationDialog: View {
    private let previousStreak: Int
    private let streak: Int
    private let isNewRecord: Bool
    private let onDismiss: () -> Void
    private let flameAnimation: LottieAnimation?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale
    @State private var displayedStreak: Int
    @State private var detailsVisible = false

    public init(
        previousStreak: Int,
        streak: Int,
        isNewRecord: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        self.previousStreak = previousStreak
        self.streak = streak
        self.isNewRecord = isNewRecord
        self.onDismiss = onDismiss
        flameAnimation = LottieAnimation.named(
            "StreakFire",
            bundle: .module
        )
        _displayedStreak = State(initialValue: previousStreak)
    }

    public var body: some View {
        ZStack {
            AppColors.shadow
                .opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                LottieView(animation: flameAnimation)
                    .looping()
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 190, height: 190)
                    .accessibilityHidden(true)

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(
                        displayedStreak.formatted(
                            .number.locale(locale)
                        )
                    )
                    .font(AppFonts.streakNumber)
                    .foregroundStyle(AppColors.reward)
                    .contentTransition(
                        .numericText(value: Double(displayedStreak))
                    )

                    Text(L10n.StreakCelebration.dayStreak)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.onAccent)
                }

                if detailsVisible {
                    VStack(spacing: 14) {
                        Text(L10n.StreakCelebration.onFire)
                            .font(AppFonts.title2Black)
                            .foregroundStyle(AppColors.onAccent)

                        Text(L10n.StreakCelebration.sameTimeTomorrow)
                            .font(AppFonts.bodyBold)
                            .foregroundStyle(AppColors.accentBlue)
                            .multilineTextAlignment(.center)

                        if isNewRecord {
                            newRecordBadge
                        }
                    }
                    .transition(
                        .move(edge: .bottom)
                        .combined(with: .opacity)
                    )
                }
            }
            .padding(.horizontal, 28)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDismiss)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text(L10n.StreakCelebration.dismiss)) {
            onDismiss()
        }
        .task {
            await runEntranceAnimation()
        }
    }

    private var newRecordBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")

            Text(L10n.StreakCelebration.newBest)
                .font(AppFonts.captionHeavy)
        }
        .foregroundStyle(AppColors.reward)
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(
            AppColors.reward.opacity(0.14),
            in: Capsule()
        )
        .overlay {
            Capsule()
                .stroke(
                    AppColors.reward.opacity(0.36),
                    lineWidth: 1
                )
        }
    }

    @MainActor
    private func runEntranceAnimation() async {
        if reduceMotion {
            displayedStreak = streak
            detailsVisible = true
            return
        }

        try? await Task.sleep(for: .milliseconds(420))
        guard !Task.isCancelled else { return }

        if previousStreak != streak {
            withAnimation(.spring(response: 0.44, dampingFraction: 0.82)) {
                displayedStreak = streak
            }
        }

        try? await Task.sleep(for: .milliseconds(520))
        guard !Task.isCancelled else { return }

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            detailsVisible = true
        }
    }
}

#Preview("Streak Celebration Light") {
    StreakCelebrationDialog(
        previousStreak: 5,
        streak: 6,
        isNewRecord: true,
        onDismiss: {}
    )
    .background(AppColors.screenBackground)
}

#Preview("Streak Celebration Dark") {
    StreakCelebrationDialog(
        previousStreak: 5,
        streak: 6,
        onDismiss: {}
    )
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
