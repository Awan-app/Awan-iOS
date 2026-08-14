//
//  InboxHeaderView.swift
//  Presentation
//

import Common
import SwiftUI

struct InboxHeaderView: View {
    @Binding var selectedTopTab: InboxTopTab
    let rewardPoints: Int?
    let pointsPulse: Int

    init(
        selectedTopTab: Binding<InboxTopTab>,
        rewardPoints: Int? = nil,
        pointsPulse: Int = 0
    ) {
        _selectedTopTab = selectedTopTab
        self.rewardPoints = rewardPoints
        self.pointsPulse = pointsPulse
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Text(L10n.Inbox.title)
                    .font(AppFonts.bigTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .layoutPriority(1)

                Spacer(minLength: 4)

                if let rewardPoints {
                    RewardStatChip(
                        icon: "star.fill",
                        value: rewardPoints.formatted(),
                        color: AppColors.reward,
                        isCompact: true
                    )
                    .symbolEffect(.bounce, value: pointsPulse)
                    .anchorPreference(
                        key: RewardAnchorKey.self,
                        value: .bounds
                    ) { ["inbox-points-badge": $0] }
                }

                AwanMascotView(state: .normal)
                    .frame(width: 64, height: 52)
            }

            AppSegmentedPicker(
                selection: $selectedTopTab,
                items: [
                    .init(value: .inbox, title: L10n.Inbox.tabInbox, icon: "tray.fill"),
                    .init(value: .goals, title: L10n.Inbox.tabGoals, icon: "target")
                ]
            )
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
