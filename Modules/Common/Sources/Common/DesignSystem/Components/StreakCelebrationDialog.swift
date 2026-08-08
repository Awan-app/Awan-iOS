//
//  StreakCelebrationDialog.swift
//  Common
//
//  Created by Eslam Elnady on 08/08/2026.
//


import SwiftUI

public struct StreakCelebrationDialog: View {
    private let streak: Int
    private let isNewRecord: Bool
    private let onDismiss: () -> Void

    @State private var appeared = false

    public init(
        streak: Int,
        isNewRecord: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        self.streak = streak
        self.isNewRecord = isNewRecord
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            AppDepthSurface(
                surfaceColor: AppColors.surface,
                borderColor: AppColors.warning.opacity(0.35),
                depthColor: AppColors.warning.opacity(0.32),
                contentInsets: EdgeInsets()
            ) {
                VStack(spacing: 18) {
                    flame

                    VStack(spacing: 7) {
                        Text(L10n.StreakCelebration.daysStreak(streak))
                            .font(AppFonts.titleBlack)
                            .foregroundStyle(AppColors.brandDarkBlue)

                        Text(L10n.StreakCelebration.subtitle)
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(
                                AppColors.textSecondary
                            )
                            .multilineTextAlignment(.center)
                    }

                    if isNewRecord {
                        newRecordBadge
                    }

                    AppButton(
                        title: L10n.StreakCelebration.keepGoing,
                        icon: "arrow.right",
                        color: AppColors.warning,
                        onTap: onDismiss
                    )
                    .frame(height: 48)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 24)
            }
            .frame(maxWidth: 310)
            .scaleEffect(appeared ? 1 : 0.88)
            .opacity(appeared ? 1 : 0)
            .padding(.horizontal, 30)
        }
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.38,
                    dampingFraction: 0.72
                )
            ) {
                appeared = true
            }
        }
    }

    private var flame: some View {
        ZStack {
            Circle()
                .fill(AppColors.warning.opacity(0.13))
                .frame(width: 72, height: 72)

            Image(systemName: "flame.fill")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(AppColors.warning)
        }
    }

    private var newRecordBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")

            Text(L10n.StreakCelebration.newBest)
                .font(AppFonts.captionHeavy)
        }
        .foregroundStyle(AppColors.warning)
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(
            AppColors.warning.opacity(0.10),
            in: Capsule()
        )
        .overlay {
            Capsule()
                .stroke(
                    AppColors.warning.opacity(0.28),
                    lineWidth: 1
                )
        }
    }
}
