import SwiftUI
import Common

struct SkipForNowLink: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Skip for now \u{2192}")
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
