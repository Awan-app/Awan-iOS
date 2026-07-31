//
//  ProposedTaskReasonChip.swift
//  Presentation
//

import Common
import SwiftUI

struct ProposedTaskReasonChip: View {
    let reason: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 13, weight: .bold))

                    Text(L10n.Home.proposedTaskReason)
                        .font(AppFonts.caption2Bold)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(isExpanded ? AppColors.accentBlue : AppColors.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    isExpanded
                        ? AppColors.accentBlue.opacity(0.12)
                        : AppColors.surface,
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isExpanded
                                ? AppColors.accentBlue.opacity(0.3)
                                : AppColors.outline.opacity(0.15),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                AppDepthSurface(
                    shape: .roundedRectangle(cornerRadius: 12),
                    surfaceColor: AppColors.infoSurface,
                    borderColor: AppColors.accentBlue.opacity(0.18),
                    depthColor: AppColors.accentBlue.opacity(0.10),
                    borderWidth: 1,
                    depthOffset: 3,
                    contentInsets: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
                ) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.accentBlue)

                        Text(reason)
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
