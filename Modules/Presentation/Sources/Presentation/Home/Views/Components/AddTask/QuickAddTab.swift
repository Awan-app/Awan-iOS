import Common
import Domain
import SwiftUI

struct QuickAddTab: View {
    let zones: [Zone]
    let onSubmit: (String, Int, UUID?, Bool) -> Void

    @Binding var quickText: String
    @Binding var useSmartDuration: Bool
    @Binding var useBestZone: Bool
    @Binding var useAutoSchedule: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            QuickAddHeader()
            QuickAddTaskInput(text: $quickText)
            QuickAddSeparator()
            QuickAddVoiceInput(quickText: $quickText)
            QuickAddChips()
            AppButton(
                title: L10n.Home.btnPlanItForMe,
                icon: nil,
                color: AppColors.accentBlue,
                onTap: submitQuickAdd
            )
            .disabled(quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1.0)
        }
    }

    private func submitQuickAdd() {
        let title = quickText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        var duration = 60
        if useSmartDuration {
            let lower = title.lowercased()
            if lower.contains("2 hour") || lower.contains("2h") || lower.contains("ساعتين") {
                duration = 120
            } else if lower.contains("30 min") || lower.contains("half hour")
                || lower.contains("نصف ساعة")
            {
                duration = 30
            } else if lower.contains("3 hour") || lower.contains("3h") {
                duration = 180
            }
        }

        var zoneID: UUID? = nil
        if useBestZone {
            let lower = title.lowercased()
            zoneID =
                zones.first(where: { lower.contains($0.name.lowercased()) })?.id ?? zones.first?.id
        }

        onSubmit(title, duration, zoneID, useAutoSchedule)
    }
}
