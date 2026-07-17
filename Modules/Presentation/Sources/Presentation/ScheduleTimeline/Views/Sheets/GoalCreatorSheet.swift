import SwiftUI

struct GoalCreatorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let zones: [TimelineZoneOption]
    let startDay: Date
    let onCreate: (String, UUID, Int) -> Void

    @State private var name = ""
    @State private var zoneID: UUID?
    @State private var durationMinutes = 45

    init(
        zones: [TimelineZoneOption],
        startDay: Date,
        onCreate: @escaping (String, UUID, Int) -> Void
    ) {
        self.zones = zones
        self.startDay = startDay
        self.onCreate = onCreate
        _zoneID = State(initialValue: zones.first(where: { $0.name == "Work" })?.id ?? zones.first?.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 58, weight: .black))
                            .foregroundStyle(Color(awanHex: "#FFD43B"))
                            .symbolEffect(.wiggle, options: .repeat(2), value: durationMinutes)
                        Text("Build a 7-day quest")
                            .font(.system(.title2, design: .rounded, weight: .black))
                        Text("One focused step every day")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.secondary)
                    }

                    PlayfulCard {
                        VStack(spacing: 18) {
                            TextField("Goal name", text: $name)
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("goal-name-field")
                            Stepper(value: $durationMinutes, in: 15...180, step: 15) {
                                HStack {
                                    Label("Each step", systemImage: "timer")
                                    Spacer()
                                    Text("\(durationMinutes) min")
                                }
                                .font(.system(.body, design: .rounded, weight: .bold))
                            }
                            Menu {
                                ForEach(zones) { zone in
                                    Button(zone.name) { zoneID = zone.id }
                                }
                            } label: {
                                HStack {
                                    Label(selectedZone?.name ?? "Choose zone", systemImage: "square.3.layers.3d")
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .font(.system(.body, design: .rounded, weight: .bold))
                                .padding(12)
                                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .tint(.primary)
                        }
                    }

                    sevenDayPreview

                    GamifiedButton(
                        title: "Start 7-day quest",
                        icon: "flag.checkered",
                        color: Color(awanHex: "#A560E8")
                    ) {
                        guard let zoneID else { return }
                        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !cleanName.isEmpty else { return }
                        onCreate(cleanName, zoneID, durationMinutes)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || zoneID == nil)
                    .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                    .accessibilityIdentifier("save-goal-button")
                }
                .padding(20)
            }
            .background(Color(awanHex: "#F7F8FC").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
        }
    }

    private var sevenDayPreview: some View {
        HStack(spacing: 7) {
            ForEach(0..<7, id: \.self) { index in
                let day = Calendar.current.date(byAdding: .day, value: index, to: startDay) ?? startDay
                VStack(spacing: 7) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(.caption, design: .rounded, weight: .heavy))
                    ZStack {
                        Circle().fill(Color(awanHex: "#A560E8").opacity(0.15))
                        Text("\(index + 1)")
                            .font(.system(.subheadline, design: .rounded, weight: .black))
                            .foregroundStyle(Color(awanHex: "#A560E8"))
                    }
                    .frame(width: 34, height: 34)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    private var selectedZone: TimelineZoneOption? {
        zones.first { $0.id == zoneID }
    }
}
