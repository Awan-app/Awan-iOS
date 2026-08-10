//
//  InboxHeaderView.swift
//  Presentation
//

import Common
import SwiftUI

struct InboxHeaderView: View {
    @Binding var selectedTopTab: InboxTopTab

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text(L10n.Inbox.title)
                    .font(AppFonts.bigTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                AwanMascotView(state: .normal)
                    .frame(width: 50, height: 40)
            }

            AppSegmentedPicker(
                selection: $selectedTopTab,
                items: [
                    .init(value: .inbox, title: L10n.Inbox.tabInbox, icon: "tray.fill"),
                    .init(value: .goals, title: L10n.Inbox.tabGoals, icon: "target")
                ]
            )

            if selectedTopTab == .inbox {
                Text(L10n.Inbox.subtitle)
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview("Inbox Header Light") {
    InboxHeaderView(selectedTopTab: .constant(.inbox))
        .padding()
        .background(AppColors.screenBackground)
}

#Preview("Inbox Header Dark") {
    InboxHeaderView(selectedTopTab: .constant(.inbox))
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
