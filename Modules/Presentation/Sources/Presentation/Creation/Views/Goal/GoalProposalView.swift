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

                        ForEach(Array(proposal.tasks.enumerated()), id: \.element.id) {
                            index,
                            task in
                            GoalProposalTaskCard(
                                task: task,
                                index: index + 1
                            )
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
    let index: Int

    private var sessionCount: Int {
        guard task.allowsTaskSplitting else { return 1 }
        return max(1, Int(ceil(Double(task.estimatedDuration) / 60)))
    }

    private var sessionLength: Int {
        Int(ceil(Double(task.estimatedDuration) / Double(sessionCount)))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.accentBlue.opacity(0.12))
                Circle()
                    .stroke(AppColors.accentBlue, lineWidth: 2)
                Text("\(index)")
                    .font(AppFonts.captionBlack)
                    .foregroundStyle(AppColors.accentBlue)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text(task.title)
                        .font(AppFonts.subheadlineBlack)
                        .foregroundStyle(AppColors.brandDarkBlue)

                    Spacer(minLength: 8)

                    Text("+\(task.estimatedPoints) pts")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                }

                Text(task.description)
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: 7) {
                    Label(
                        "\(task.estimatedDuration) min",
                        systemImage: "clock.fill"
                    )

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
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.accentBlue)
            }
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.accentBlue)
                    .offset(y: 4)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.surface)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.05))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.55), lineWidth: 1.5)
        }
        .padding(.bottom, 4)
    }
}


