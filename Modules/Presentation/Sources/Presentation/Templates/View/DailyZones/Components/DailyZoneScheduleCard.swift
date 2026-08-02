import Common
import SwiftUI

struct DailyZoneScheduleCard: View {
    let viewModel: DailyZonesViewModel
    let zone: DailyZoneDraft
    let editable: Bool

    var body: some View {
        let color = AppColors.runtime(hex: zone.color.hex)
        HStack(spacing: 12) {
            Image(systemName: "circle.grid.3x3.fill")
                .font(AppFonts.captionIconBlack)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(zone.name)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textPrimary)
                Text(
                    L10n.Templates.zoneTimeRange(
                        viewModel.formattedTime(zone.startTime),
                        viewModel.formattedTime(zone.endTime)
                    )
                )
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            if editable {
                Menu {
                    Button(L10n.Templates.edit, systemImage: "pencil") {
                        viewModel.send(.presentEditZone(zone.id))
                    }
                    Button(L10n.Templates.delete, systemImage: "trash", role: .destructive) {
                        viewModel.send(.requestDeleteZone(zone.id))
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(AppFonts.progressSymbol)
                        .foregroundStyle(color)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.25), lineWidth: 1)
        }
        .frame(maxWidth: .infinity)
        .confirmationDialog(
            L10n.Templates.deleteZoneConfirmation(zone.name),
            isPresented: deletionDialogBinding,
            titleVisibility: .visible
        ) {
            Button(L10n.Templates.delete, role: .destructive) {
                viewModel.send(.confirmDialog)
            }
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelDialog)
            }
        } message: {
            Text(L10n.Templates.zoneRemovalMessage)
        }
    }

    private var deletionDialogBinding: Binding<Bool> {
        Binding(
            get: {
                guard case .deleteZone(let selectedZone) = viewModel.state.dialog else {
                    return false
                }
                return selectedZone.id == zone.id
            },
            set: { if !$0 { viewModel.send(.cancelDialog) } }
        )
    }
}
