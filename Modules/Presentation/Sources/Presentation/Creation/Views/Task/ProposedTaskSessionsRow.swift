//
//  ProposedTaskSessionsRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProposedTaskSessionsRow: View {
    let fixedSessions: [ProposedSession]
    let aiSessions: [ProposedSession]
    let onEditSession: (ProposedSessionSource, ProposedSession) -> Void
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !fixedSessions.isEmpty {
                sessionGroup(
                    icon: "pin.fill",
                    label: L10n.Home.proposedTaskFixedSession,
                    color: AppColors.accentPurple,
                    sessions: fixedSessions,
                    source: .fixed
                )
            }

            if !aiSessions.isEmpty {
                sessionGroup(
                    icon: "sparkles",
                    label: L10n.Home.proposedTaskAiSession,
                    color: AppColors.accentBlue,
                    sessions: aiSessions,
                    source: .ai
                )
            }
        }
    }

    @ViewBuilder
    private func sessionGroup(
        icon: String,
        label: String,
        color: Color,
        sessions: [ProposedSession],
        source: ProposedSessionSource
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(AppFonts.caption2Bold)
                Text(label)
                    .font(AppFonts.caption2Bold)
            }
            .foregroundStyle(color)

            VStack(spacing: 8) {
                ForEach(sessions) { session in
                    Button {
                        onEditSession(source, session)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .font(AppFonts.captionIconBlack)
                                .foregroundStyle(color)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(formatted(session.start))
                                Text(formatted(session.end))
                            }
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)

                            Spacer(minLength: 8)

                            Image(systemName: "pencil")
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(
                        AppDepthButtonStyle(
                            shape: .roundedRectangle(cornerRadius: 12),
                            surfaceColor: AppColors.surface,
                            borderColor: color.opacity(0.22),
                            depthColor: color.opacity(0.22),
                            depthOffset: 3
                        )
                    )
                }
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        var calendar = Calendar.current
        calendar.locale = locale

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        let time = timeFormatter.string(from: date)

        if calendar.isDateInToday(date) {
            return L10n.Home.sessionTodayAt(time)
        }
        if calendar.isDateInTomorrow(date) {
            return L10n.Home.sessionTomorrowAt(time)
        }

        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.locale = locale
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .short
        return dateTimeFormatter.string(from: date)
    }
}
