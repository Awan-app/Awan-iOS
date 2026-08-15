import Common
import Domain
import Foundation
import SwiftUI

struct SessionDetailsStatusUIModel {
    let title: String
    let icon: String
    let foregroundColor: Color
    let surfaceColor: Color
    let borderColor: Color
    let depthColor: Color
}

struct SessionDetailsStatusUIFactory {
    private let displayStatusFactory = SessionDisplayStatusFactory()

    func make(
        session: Session,
        now: Date = Date()
    ) -> SessionDetailsStatusUIModel {
        switch displayStatusFactory.make(session: session, now: now) {
        case .scheduled:
            SessionDetailsStatusUIModel(
                title: L10n.Home.sessionScheduled,
                icon: "clock.fill",
                foregroundColor: AppColors.accentBlue,
                surfaceColor: AppColors.infoSurface,
                borderColor: AppColors.accentBlue.opacity(0.18),
                depthColor: AppColors.accentBlueDepth.opacity(0.35)
            )
        case .activeNow:
            SessionDetailsStatusUIModel(
                title: L10n.Inbox.sessionsActiveNow,
                icon: "play.circle.fill",
                foregroundColor: AppColors.accentGreen,
                surfaceColor: AppColors.successSurface,
                borderColor: AppColors.accentGreen,
                depthColor: AppColors.accentGreenDepth
            )
        case .missed:
            SessionDetailsStatusUIModel(
                title: L10n.Home.sessionMissed,
                icon: "exclamationmark.circle.fill",
                foregroundColor: AppColors.destructive,
                surfaceColor: AppColors.destructiveSurface,
                borderColor: AppColors.destructive,
                depthColor: AppColors.destructive
            )
        case .completed:
            SessionDetailsStatusUIModel(
                title: L10n.Home.sessionCompleted,
                icon: "checkmark.circle.fill",
                foregroundColor: AppColors.accentGreen,
                surfaceColor: AppColors.successSurface,
                borderColor: AppColors.accentGreen,
                depthColor: AppColors.accentGreenDepth
            )
        case .cancelled:
            SessionDetailsStatusUIModel(
                title: L10n.Home.sessionCancelled,
                icon: "xmark.circle.fill",
                foregroundColor: AppColors.destructive,
                surfaceColor: AppColors.destructiveSurface,
                borderColor: AppColors.destructive,
                depthColor: AppColors.destructive
            )
        }
    }
}
