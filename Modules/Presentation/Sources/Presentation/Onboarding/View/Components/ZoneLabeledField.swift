import SwiftUI
import Common

struct ZoneLabeledField<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(_ title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.textSecondary)
            content
        }
    }
}


#Preview {
    ZoneLabeledField("Name", icon: "pencil") {
        Text("Content")
    }
    .padding()
}

