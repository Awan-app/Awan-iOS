import Common
import SwiftUI

struct DurationStepperControl: View {
    @Binding var durationMinutes: Int

    let range: ClosedRange<Int>
    let step: Int

    init(
        durationMinutes: Binding<Int>,
        range: ClosedRange<Int> = 15...480,
        step: Int = 15
    ) {
        _durationMinutes = durationMinutes
        self.range = range
        self.step = step
    }

    var body: some View {
        HStack(spacing: 10) {
            stepButton(icon: "minus", isEnabled: durationMinutes > range.lowerBound) {
                durationMinutes = max(range.lowerBound, durationMinutes - step)
            }

            Text(durationText)
                .font(AppFonts.bodyBold)
                .foregroundStyle(AppColors.brandDarkBlue)
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            stepButton(icon: "plus", isEnabled: durationMinutes < range.upperBound) {
                durationMinutes = min(range.upperBound, durationMinutes + step)
            }
        }
    }

    private func stepButton(
        icon: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 28, height: 28)
                .background(AppColors.infoSurface, in: Circle())
                .overlay {
                    Circle()
                        .stroke(AppColors.accentBlue.opacity(0.24), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var durationText: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let minutes = durationMinutes % 60
            return minutes == 0
                ? L10n.Home.hoursShort(hours)
                : L10n.Home.hoursMinutesShort(hours, minutes)
        }
        return L10n.Home.minutesShort(durationMinutes)
    }
}
