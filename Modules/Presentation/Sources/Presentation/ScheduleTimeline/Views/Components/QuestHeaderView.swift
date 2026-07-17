import SwiftUI

struct QuestHeaderView: View {
    let selectedDayTitle: String
    let scheduledMinutes: Int
    let goalProgress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AWAN QUESTS")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .foregroundStyle(Color(awanHex: "#58CC02"))
                        .tracking(1.2)
                    Text(selectedDayTitle)
                        .font(.system(.title2, design: .rounded, weight: .black))
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color(awanHex: "#FF9600"))
                    Text("7")
                        .font(.system(.headline, design: .rounded, weight: .black))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(awanHex: "#FFF3D6"), in: Capsule())
                .accessibilityLabel("Seven day streak")
            }

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color(awanHex: "#E6E8EF"), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: max(0.08, min(goalProgress, 1)))
                        .stroke(
                            Color(awanHex: "#58CC02"),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: goalProgress)
                    Image(systemName: goalProgress > 0 ? "flag.checkered" : "star.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(Color(awanHex: goalProgress > 0 ? "#A560E8" : "#FFD43B"))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(goalProgress > 0 ? "Quest chain" : "Today's adventure")
                            .font(.system(.headline, design: .rounded, weight: .black))
                        Spacer()
                        Text("\(scheduledMinutes) min")
                            .font(.system(.subheadline, design: .rounded, weight: .heavy))
                            .foregroundStyle(Color(awanHex: "#1CB0F6"))
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(awanHex: "#E6E8EF"))
                            Capsule()
                                .fill(Color(awanHex: goalProgress > 0 ? "#A560E8" : "#1CB0F6"))
                                .frame(
                                    width: geometry.size.width * max(
                                        0.06,
                                        goalProgress > 0 ? goalProgress : min(Double(scheduledMinutes) / 240, 1)
                                    )
                                )
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1.5)
        }
        .shadow(color: Color.black.opacity(0.07), radius: 18, y: 8)
    }
}
