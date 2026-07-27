import Common
import Domain
import SwiftUI

struct SessionTimeSheet: View {
    let initialDuration: Int
    let onSave: (Int) -> Void
    let onDismiss: () -> Void

    @State private var selectedIndex: Int

    private let durationValues = [15, 30, 45, 60, 90, 120, 150, 180]
    private let durationLabels = ["15m", "30m", "45m", "1h", "1.5h", "2h", "2.5h", "3h"]

    init(
        initialDuration: Int,
        onSave: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialDuration = initialDuration
        self.onSave = onSave
        self.onDismiss = onDismiss

        let defaultIndex = [15, 30, 45, 60, 90, 120, 150, 180].firstIndex(of: initialDuration) ?? 3
        _selectedIndex = State(initialValue: defaultIndex)
    }

    private var currentDuration: Int {
        durationValues[selectedIndex]
    }

    private var formattedDurationText: String {
        let mins = currentDuration
        if mins < 60 {
            return L10n.Home.minutesShort(mins)
        } else if mins % 60 == 0 {
            return "\(mins / 60) h"
        } else {
            return String(format: "%.1f h", Double(mins) / 60.0)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header bar
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

            // Value Display Card using AppCard
            AppCard {
                VStack(spacing: 20) {
                    Text(formattedDurationText)
                        .font(AppFonts.title2Black)
                        .foregroundStyle(AppColors.textPrimary)

                    // Step Slider Control
                    GeometryReader { geometry in
                        let stepWidth = (geometry.size.width - 28) / CGFloat(durationLabels.count - 1)

                        ZStack(alignment: .leading) {
                            // Track
                            Capsule()
                                .fill(AppColors.outline.opacity(0.3))
                                .frame(height: 8)

                            // Fill
                            Capsule()
                                .fill(AppColors.accentBlue)
                                .frame(
                                    width: max(
                                        8,
                                        stepWidth * CGFloat(selectedIndex) + 14
                                    ),
                                    height: 8
                                )

                            // Thumb
                            Circle()
                                .fill(AppColors.surface)
                                .frame(width: 28, height: 28)
                                .shadow(color: AppColors.shadow.opacity(0.15), radius: 4, y: 2)
                                .overlay(
                                    Circle().stroke(AppColors.accentBlue, lineWidth: 2.5)
                                )
                                .offset(x: stepWidth * CGFloat(selectedIndex))
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { gesture in
                                            let newIndex = Int(round(gesture.location.x / stepWidth))
                                            let clamped = min(max(0, newIndex), durationLabels.count - 1)
                                            if clamped != selectedIndex {
                                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                                    selectedIndex = clamped
                                                }
                                            }
                                        }
                                )
                        }
                    }
                    .frame(height: 30)

                    // Labels below slider
                    HStack {
                        ForEach(0..<durationLabels.count, id: \.self) { index in
                            Text(durationLabels[index])
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(
                                    selectedIndex == index ? AppColors.accentBlue : AppColors.textSecondary
                                )
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        selectedIndex = index
                                    }
                                }
                        }
                    }
                }
            }

            Spacer()

            // 3D Save Button using AppButton
            AppButton(
                title: L10n.Common.save,
                icon: "checkmark.circle.fill",
                color: AppColors.accentBlue,
                size: .large,
                onTap: {
                    onSave(currentDuration)
                }
            )
        }
        .padding(20)
        .background(AppColors.screenBackground.ignoresSafeArea())
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
