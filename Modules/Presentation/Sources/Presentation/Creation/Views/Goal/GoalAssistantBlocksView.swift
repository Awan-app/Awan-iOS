import Common
import Domain
import SwiftUI

struct GoalAssistantBlocksView: View {
    let blocks: [GoalDecompositionBlock]
    let onOptionSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            GoalAssistantIdentityView()

            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 22),
                surfaceColor: AppColors.infoSurface,
                borderColor: AppColors.accentBlue.opacity(0.22),
                depthColor: AppColors.accentBlue.opacity(0.18),
                depthOffset: 5
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                        switch block {
                        case .text(let text):
                            GoalAssistantMessageView(
                                text: text,
                                showsDivider: index > 0
                            )
                        case .question(let question):
                            GoalAssistantMessageView(
                                text: question.text,
                                showsDivider: index > 0
                            )
                        case .proposal:
                            EmptyView()
                        }
                    }
                }
            }

            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                if case .question(let question) = block {
                    GoalAnswerOptionsView(
                        options: question.options,
                        onOptionSelected: onOptionSelected
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GoalAssistantIdentityView: View {
    var body: some View {
        HStack(spacing: 12) {
            AwanMascotView(state: .goal)
                .frame(width: 94, height: 70)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.GoalCreation.assistantName.uppercased())
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.accentBlue)

                Text(L10n.GoalCreation.assistantStatus)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.brandDarkBlue)
            }
        }
    }
}

private struct GoalAssistantMessageView: View {
    let text: String
    let showsDivider: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showsDivider {
                Rectangle()
                    .fill(AppColors.accentBlue.opacity(0.14))
                    .frame(height: 1)
            }

            Text(text)
                .font(AppFonts.bodySemibold)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct GoalAnswerOptionsView: View {
    let options: [String]
    let onOptionSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Label(
                L10n.GoalCreation.chooseAnswer,
                systemImage: "sparkles"
            )
            .font(AppFonts.captionHeavy)
            .foregroundStyle(AppColors.accentBlue)
            .textCase(.uppercase)

            ForEach(options, id: \.self) { option in
                Button {
                    onOptionSelected(option)
                } label: {
                    HStack(spacing: 12) {
                        Text(option)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 8)

                        Image(systemName: "arrow.right")
                            .font(AppFonts.captionIconBlack)
                            .foregroundStyle(AppColors.accentBlue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        shape: .roundedRectangle(cornerRadius: 14),
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.accentBlue.opacity(0.32),
                        depthColor: AppColors.accentBlueDepth.opacity(0.7),
                        depthOffset: 3
                    )
                )
            }
        }
    }
}

#Preview {
    GoalAssistantBlocksView(
        blocks: [
            .text("I’ll turn that into a plan you can actually finish."),
            .question(
                GoalDecompositionQuestion(
                    text: "How much time would you like to give yourself?",
                    options: ["2–4 weeks", "1–2 months", "3–6 months"]
                )
            )
        ],
        onOptionSelected: { _ in }
    )
    .padding()
    .background(AppColors.screenBackground)
}
