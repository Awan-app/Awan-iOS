import SwiftUI
import Common

struct ZoneSheetHeader: View {
    let iconName: String
    let title: String
    let selectedColor: Color
    let bounceValue: Int

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(AppFonts.heroSymbol)
                .foregroundStyle(selectedColor)
                .symbolEffect(.bounce, value: bounceValue)
            Text(title)
                .font(AppFonts.title2Black)
        }
    }
}


#Preview {
    ZoneSheetHeader(iconName: "star", title: "Add Zone", selectedColor: .blue, bounceValue: 0)
        .padding()
}

