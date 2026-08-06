import Common
import Domain
import SwiftUI

struct GoalProposalView: View {
    let narration: [String]
    let proposal: GoalProposal
    @Binding var prompt: String
    let isRecording: Bool
    let onSend: () -> Void
    let onOptionSelected: (String) -> Void
    let onRecordingStarted: () -> Void
    let onRecordingEnded: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if !narration.isEmpty {
                        GoalAssistantBlocksView(
                            blocks: narration.map(GoalDecompositionBlock.text),
                            onOptionSelected: onOptionSelected
                        )
                    }

                    goalHeader

                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.GoalCreation.sessions.uppercased())
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.accentBlue)

                        ForEach(proposal.tasks) { task in
                            GoalProposalTaskCard(task: task)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            VStack(spacing: 13) {
                QuickTaskComposer(
                    text: $prompt,
                    isRecording: isRecording,
                    placeholder: L10n.GoalCreation.modifyPlaceholder,
                    sendAccessibilityLabel: L10n.GoalCreation.sendPrompt,
                    recordingAccessibilityLabel: L10n.Home.tellAwan,
                    onSend: onSend,
                    onRecordingStarted: onRecordingStarted,
                    onRecordingEnded: onRecordingEnded
                )

                AppButton(
                    title: L10n.GoalCreation.confirm,
                    icon: "checkmark.circle.fill",
                    color: AppColors.accentGreen,
                    onTap: onConfirm
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 18)
            .background(AppColors.screenBackground)
        }
    }

    private var goalHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "target")
                    .font(AppFonts.progressSymbol)
                    .foregroundStyle(AppColors.onAccent)
                    .frame(width: 42, height: 42)
                    .background(AppColors.accentBlue, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(proposal.title)
                        .font(AppFonts.title2Black)
                        .foregroundStyle(AppColors.brandDarkBlue)

                    if let targetDate = proposal.targetDate {
                        Label(
                            targetDate.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                    }
                }
            }

            Text(proposal.description)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.24), lineWidth: 1.5)
        }
    }
}

private struct GoalProposalTaskCard: View {
    let task: GoalTaskProposal

    private var sessionCount: Int {
        guard task.allowsTaskSplitting else { return 1 }
        return max(1, Int(ceil(Double(task.estimatedDuration) / 60)))
    }

    private var sessionLength: Int {
        Int(ceil(Double(task.estimatedDuration) / Double(sessionCount)))
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(AppFonts.headlineBlack)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(task.description)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Divider()

                HStack(spacing: 8) {
                    if let category = task.category {
                        Label(category.name, systemImage: "tag.fill")
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                AppColors.accentBlue.opacity(0.12),
                                in: Capsule()
                            )
                    }

                    Spacer()

                    Label("\(task.estimatedPoints) pts", systemImage: "star.fill")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.reward)
                        .environment(\.layoutDirection, .leftToRight)
                }

                HStack {
                    Text(L10n.Home.duration)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    Text(L10n.Home.minutesShort(task.estimatedDuration))
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                }

                HStack {
                    Text(L10n.GoalCreation.sessions)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    if sessionCount > 1 {
                        Label(
                            "\(sessionCount) × \(sessionLength) min",
                            systemImage: "rectangle.stack.fill"
                        )
                    } else {
                        Label(
                            L10n.GoalCreation.oneSession,
                            systemImage: "rectangle.fill"
                        )
                    }
                }
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)
            }
        }
    }
}
