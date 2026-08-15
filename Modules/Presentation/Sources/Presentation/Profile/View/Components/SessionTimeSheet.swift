import Common
import Domain
import SwiftUI

struct SessionTimeSheet: View {
    let initialDuration: Int
    let onSave: (Int) -> Void
    let onDismiss: () -> Void

    @State private var selectedDuration: Int
    @State private var customDurationText: String
    @State private var showValidationError: Bool = false

    private let defaultSessionDurations = [10, 20, 30, 40, 50, 60, 75, 90, 105, 120, 150, 180]

    init(
        initialDuration: Int,
        onSave: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialDuration = initialDuration
        self.onSave = onSave
        self.onDismiss = onDismiss

        _selectedDuration = State(initialValue: initialDuration)
        _customDurationText = State(initialValue: String(initialDuration))
    }

    private var dynamicLabels: [String] {
        defaultSessionDurations.map { duration in
            switch duration {
            case 10: return "10m"
            case 60: return "1h"
            case 120: return "2h"
            case 180: return "3h"
            default: return ""
            }
        }
    }

    private var focusDurationText: String {
        let minutes = selectedDuration
        if minutes < 60 {
            return L10n.Onboarding.durationMinutes(minutes)
        } else if minutes == 60 {
            return L10n.Onboarding.durationOneHour
        } else if minutes % 60 == 0 {
            return L10n.Onboarding.durationHours(minutes / 60)
        } else {
            return L10n.Onboarding.durationHoursMinutes(minutes / 60, minutes % 60)
        }
    }

    var body: some View {
        AppSheet(
            sizing: .content(initialHeight: 370, maximumHeight: 600),
            backgroundColor: AppColors.screenBackground
        ) {
            VStack(spacing: 16) {
                // Header bar with existing Profile title
                HStack {
                    Text(L10n.Profile.sessionTime)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.brandDarkBlue)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                TaskLengthValueDisplay(focusDurationText: focusDurationText)

                TaskLengthSlider(
                    focusDurationIndex: Binding(
                        get: { defaultSessionDurations.firstIndex(of: selectedDuration) ?? 0 },
                        set: { newIndex in
                            let newValue = defaultSessionDurations[newIndex]
                            selectedDuration = newValue
                            customDurationText = String(newValue)
                            showValidationError = false
                        }
                    ),
                    labels: dynamicLabels
                )

                VStack(spacing: 6) {
                    AppTextField(
                        text: $customDurationText,
                        placeholder: L10n.Onboarding.customTimePlaceholder
                    )
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 24)

                    if showValidationError {
                        Text(L10n.Onboarding.timeValidationError)
                            .foregroundColor(AppColors.destructive)
                            .font(AppFonts.captionHeavy)
                    }
                }
                .onChange(of: customDurationText) { _, newValue in
                    if let custom = Int(newValue) {
                        if custom >= 10 && custom <= 180 {
                            selectedDuration = custom
                            showValidationError = false
                        }
                    }
                }

                AppButton(
                    title: L10n.Common.save,
                    icon: nil,
                    color: AppColors.accentBlue,
                    foregroundColor: AppColors.onAccent,
                    size: .large,
                    onTap: { handleSave() }
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    private func handleSave() {
        if !customDurationText.isEmpty {
            if let custom = Int(customDurationText), custom >= 10, custom <= 180 {
                selectedDuration = custom
                showValidationError = false
                onSave(custom)
            } else {
                showValidationError = true
            }
        } else {
            showValidationError = false
            onSave(selectedDuration)
        }
    }
}

#if DEBUG
#Preview {
    SessionTimeSheet(
        initialDuration: 60,
        onSave: { _ in },
        onDismiss: {}
    )
}
#endif
