//
//  MarketplacePurchaseFeedbackBanner.swift
//  Presentation
//

import Common
import SwiftUI

struct MarketplacePurchaseFeedbackBanner: View {
    let feedback: PurchaseFeedback

    @State private var appeared = false

    private var isSuccess: Bool {
        if case .success = feedback { return true }
        return false
    }

    private var message: String {
        switch feedback {
        case let .success(message): message
        case let .failure(message): message
        }
    }

    private var title: String {
        isSuccess ? L10n.Marketplace.purchaseSuccessTitle : L10n.Marketplace.purchaseFailedTitle
    }

    private var accentColor: Color {
        isSuccess ? AppColors.accentGreen : AppColors.destructive
    }

    private var depthColor: Color {
        isSuccess ? AppColors.accentGreenDepth : AppColors.destructive.opacity(0.45)
    }

    private var iconName: String {
        isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            surfaceColor: AppColors.surface,
            borderColor: accentColor.opacity(0.30),
            depthColor: depthColor.opacity(0.35),
            borderWidth: 1.5,
            depthOffset: 4,
            contentInsets: EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        ) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(message)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .offset(y: appeared ? 0 : 80)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.75)) {
                appeared = true
            }
        }
        .onChange(of: feedback) { _, _ in
            appeared = false
            withAnimation(.spring(response: 0.42, dampingFraction: 0.75)) {
                appeared = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}
