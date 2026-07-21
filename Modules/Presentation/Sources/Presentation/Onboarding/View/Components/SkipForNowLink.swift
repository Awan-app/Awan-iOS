import SwiftUI
import Common

struct SkipForNowLink: View {
    var title: String = "Skip for now \u{2192}"
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.captionHeavy) // using a heavy/bold caption equivalent
                .foregroundColor(AppColors.accentBlue)
        }
    }
}

#Preview {
    ZStack {
        AppColors.screenBackground.ignoresSafeArea()
        SkipForNowLink {}
    }
}
