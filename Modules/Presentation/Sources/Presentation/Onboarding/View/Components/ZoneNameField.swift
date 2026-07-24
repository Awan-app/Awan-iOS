import SwiftUI
import Common

struct ZoneNameField: View {
    @Binding var zoneName: String
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Onboarding.zoneNameLabel)
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(AppColors.brandDarkBlue)
                .kerning(1.2)

            TextField(
                "",
                text: $zoneName,
                prompt: Text(L10n.Onboarding.zoneNamePlaceholder)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .font(.system(.body, design: .rounded, weight: .semibold))
            .padding()
            .focused($isNameFocused)
            .background(
                AppColors.surface,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        (isNameFocused || !zoneName.isEmpty)
                            ? AppColors.accentBlue
                            : AppColors.brandDarkBlue.opacity(0.15),
                        lineWidth: 1.5
                    )
            }
            .accessibilityIdentifier("zone-name-field")
        }
    }
}
