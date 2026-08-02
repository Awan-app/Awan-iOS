import Common
import Domain
import SwiftUI

struct GoalAssistantBlocksView: View {
    let blocks: [GoalDecompositionBlock]
    let onOptionSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            AwanMascotView()
                .frame(width: 116, height: 86)

            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .text(let text):
                    replyBubble(text)
                case .question(let question):
                    questionView(question)
                case .proposal:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func questionView(
        _ question: GoalDecompositionQuestion
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            replyBubble(question.text)

            FlowLayout(spacing: 9) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        onOptionSelected(option)
                    } label: {
                        Text(option)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 11)
                            .background(
                                AppColors.surface,
                                in: Capsule()
                            )
                            .overlay {
                                Capsule()
                                    .stroke(
                                        AppColors.accentBlue.opacity(0.45),
                                        lineWidth: 1.5
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func replyBubble(_ text: String) -> some View {
        Text(text)
            .font(AppFonts.bodySemibold)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                AppColors.infoSurface,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(AppColors.infoSurface)
                    .frame(width: 15, height: 15)
                    .offset(x: 18, y: -5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let result = layout(
            proposal: proposal,
            subviews: subviews
        )
        return result.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = layout(
            proposal: ProposedViewSize(
                width: bounds.width,
                height: proposal.height
            ),
            subviews: subviews
        )

        for (index, point) in result.points.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private func layout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (size: CGSize, points: [CGPoint], sizes: [CGSize]) {
        let maxWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let idealSize = subview.sizeThatFits(.unspecified)
            let proposedWidth = maxWidth.isFinite
                ? min(idealSize.width, maxWidth)
                : idealSize.width
            let size = subview.sizeThatFits(
                ProposedViewSize(width: proposedWidth, height: nil)
            )
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            sizes.append(size)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (
            CGSize(
                width: proposal.width ?? max(0, x - spacing),
                height: y + rowHeight
            ),
            points,
            sizes
        )
    }
}


#Preview {
    GoalAssistantBlocksView(blocks: [], onOptionSelected: { _ in })
        .padding()
}
