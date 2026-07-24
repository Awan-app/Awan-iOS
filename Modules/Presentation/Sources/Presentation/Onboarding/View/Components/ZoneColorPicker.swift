import SwiftUI
import Common

struct ZoneColorPicker: View {
    @Binding var selectedColorIndex: Int

    var body: some View {
        ZoneLabeledField(L10n.Onboarding.zoneColorLabel, icon: "paintpalette.fill") {
            HStack(spacing: 10) {
                ForEach(ZoneColorPalette.colors.indices, id: \.self) { index in
                    let palette = ZoneColorPalette.colors[index]
                    let color = Color(red: palette.red, green: palette.green, blue: palette.blue)
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedColorIndex = index
                        }
                    } label: {
                        Circle()
                            .fill(color.gradient)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if selectedColorIndex == index {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(.white)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .overlay {
                                Circle()
                                    .stroke(
                                        selectedColorIndex == index
                                            ? color.opacity(0.8)
                                            : Color.clear,
                                        lineWidth: 2.5
                                    )
                                    .frame(width: 36, height: 36)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(palette.label)
                    .accessibilityIdentifier("zone-color-\(index)")
                }
            }
        }
    }
}
