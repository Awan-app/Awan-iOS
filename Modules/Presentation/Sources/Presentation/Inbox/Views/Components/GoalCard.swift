//
//  GoalCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalCard: View {
    let goal: Goal
    var progress: Double = 0.0 // 0.0 to 1.0
    var onTap: (() -> Void)? = nil

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private var deadlineText: String? {
        guard let deadline = goal.deadline else { return nil }
        return Self.dateFormatter.string(from: deadline)
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 24),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.12),
                depthColor: AppColors.outline.opacity(0.10),
                borderWidth: 1.5,
                depthOffset: 4,
                contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.name)
                                .font(AppFonts.headlineBlack)
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.leading)

                            if let desc = goal.description, !desc.isEmpty {
                                Text(desc)
                                    .font(AppFonts.subheadlineSemibold)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.forward")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                            .flipsForRightToLeftLayoutDirection(true)
                    }

                    if let deadlineStr = deadlineText {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.accentBlue)

                            Text(deadlineStr)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppColors.accentBlue.opacity(0.08))
                        )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppColors.outline.opacity(0.12))
                                    .frame(height: 6)

                                Capsule()
                                    .fill(AppColors.accentBlue)
                                    .frame(width: max(0, min(geometry.size.width * progress, geometry.size.width)), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(goal.name), \(goal.description ?? ""), \(deadlineText ?? L10n.Goals.noDeadline)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("GoalCard Light") {
    GoalCard(
        goal: Goal(
            id: UUID(),
            name: "Launch iOS App",
            description: "Finish presentation layer and publish to App Store.",
            status: .active,
            deadline: Date().addingTimeInterval(86400 * 7)
        ),
        progress: 0.65
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("GoalCard Dark") {
    GoalCard(
        goal: Goal(
            id: UUID(),
            name: "Master Swift Concurrency",
            description: "Read structured concurrency docs and practice.",
            status: .active,
            deadline: nil
        ),
        progress: 0.3
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
