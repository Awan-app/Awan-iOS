import SwiftUI

extension Color {
    init(awanHex hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

struct PressedDepthButtonStyle: ButtonStyle {
    let color: Color
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded, weight: .heavy))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1.5)
            }
            .shadow(color: color.opacity(0.75), radius: 0, y: configuration.isPressed ? 2 : 5)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

struct GamifiedButton: View {
    let title: String
    let icon: String
    let color: Color
    var compact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .lineLimit(1)
                .padding(.horizontal, compact ? 2 : 8)
        }
        .buttonStyle(PressedDepthButtonStyle(color: color))
        .accessibilityLabel(title)
    }
}

struct PlayfulCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1.5)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 18, y: 8)
    }
}
