//
//  InboxEmptyView.swift
//  Presentation
//

import Common
import SwiftUI

struct InboxEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            AwanMascotView(state: .normal)
                .frame(width: 140, height: 110)

            Text(L10n.Inbox.emptyTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.Inbox.emptySubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
