import SwiftUI

struct GamifiedNudgeView: View {
    let model: TimelineNudgeModel
    let onAction: (TimelineNudgeAction) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 44, height: 5)

            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle().fill(Color(awanHex: "#EAF9FF"))
                    Image(systemName: model.icon)
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(Color(awanHex: "#1CB0F6"))
                        .symbolEffect(.bounce, options: .repeat(2))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.title)
                        .font(.system(.title3, design: .rounded, weight: .black))
                    Text(model.message)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(model.actions) { action in
                    Button { onAction(action) } label: {
                        HStack(spacing: 10) {
                            Image(systemName: action.icon)
                                .frame(width: 22)
                            Text(action.title)
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.black))
                                .opacity(0.75)
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(
                            Color(awanHex: action.colorHex),
                            in: RoundedRectangle(cornerRadius: 15)
                        )
                        .shadow(
                            color: Color(awanHex: action.colorHex).opacity(0.7),
                            radius: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("nudge-action-\(action.title)")
                }
            }
            .padding(.bottom, 5)
        }
        .padding(18)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.8), lineWidth: 1.5)
        }
        .shadow(color: Color.black.opacity(0.17), radius: 24, y: 12)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}
