import SwiftUI

struct TaskEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let task: TimelineTaskEditorModel?
    let zones: [TimelineZoneOption]
    let selectedDay: Date
    let onSave: (String, Int, UUID?, Bool) -> Void
    let onDelete: (() -> Void)?

    @State private var title: String
    @State private var durationMinutes: Int
    @State private var zoneID: UUID?
    @State private var isSplittable: Bool

    init(
        task: TimelineTaskEditorModel?,
        zones: [TimelineZoneOption],
        selectedDay: Date,
        onSave: @escaping (String, Int, UUID?, Bool) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.task = task
        self.zones = zones
        self.selectedDay = selectedDay
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: task?.title ?? "")
        _durationMinutes = State(initialValue: task?.durationMinutes ?? 60)
        _zoneID = State(initialValue: task?.zoneID ?? zones.first?.id)
        _isSplittable = State(initialValue: task?.isSplittable ?? true)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    mascotHeader
                    PlayfulCard {
                        VStack(alignment: .leading, spacing: 18) {
                            labeledField("Quest name", icon: "pencil.line") {
                                TextField("What will you conquer?", text: $title)
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                                    .textFieldStyle(.roundedBorder)
                                    .accessibilityIdentifier("task-title-field")
                            }
                            labeledField("Duration", icon: "timer") {
                                Stepper(value: $durationMinutes, in: 15...480, step: 15) {
                                    Text("\(durationMinutes) minutes")
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                }
                                .accessibilityIdentifier("task-duration-stepper")
                            }
                            labeledField("Zone", icon: "square.3.layers.3d") {
                                Menu {
                                    Button("Standalone") { zoneID = nil }
                                    ForEach(zones) { zone in
                                        Button(zone.name) { zoneID = zone.id }
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(selectedZoneColor)
                                            .frame(width: 13, height: 13)
                                        Text(selectedZoneName)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                                }
                                .tint(.primary)
                                .accessibilityIdentifier("task-zone-menu")
                            }
                            Toggle(isOn: $isSplittable) {
                                Label("Can split into sessions", systemImage: "rectangle.split.2x1")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                            }
                            .tint(Color(awanHex: "#58CC02"))
                        }
                    }

                    GamifiedButton(
                        title: task == nil ? "Create quest" : "Save changes",
                        icon: task == nil ? "sparkles" : "checkmark.seal.fill",
                        color: Color(awanHex: "#58CC02")
                    ) {
                        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !cleanTitle.isEmpty else { return }
                        onSave(cleanTitle, durationMinutes, zoneID, isSplittable)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                    .accessibilityIdentifier("save-task-button")

                    if let onDelete {
                        GamifiedButton(
                            title: "Delete quest",
                            icon: "trash.fill",
                            color: Color(awanHex: "#FF4B4B")
                        ) {
                            onDelete()
                            dismiss()
                        }
                    }
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

    private var mascotHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: task == nil ? "star.bubble.fill" : "pencil.and.scribble")
                .font(.system(size: 52, weight: .black))
                .foregroundStyle(Color(awanHex: task == nil ? "#A560E8" : "#1CB0F6"))
                .symbolEffect(.bounce, value: durationMinutes)
            Text(task == nil ? "New daily quest" : "Tune your quest")
                .font(.system(.title2, design: .rounded, weight: .black))
            Text(selectedDay.formatted(.dateTime.weekday(.wide).month().day()))
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.secondary)
        }
    }

    private func labeledField<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(.subheadline, design: .rounded, weight: .heavy))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private var selectedZoneName: String {
        guard let zoneID else { return "Standalone" }
        return zones.first(where: { $0.id == zoneID })?.name ?? "Choose zone"
    }

    private var selectedZoneColor: Color {
        guard let zoneID, let zone = zones.first(where: { $0.id == zoneID }) else {
            return .gray
        }
        return Color(awanHex: zone.colorHex)
    }
}
