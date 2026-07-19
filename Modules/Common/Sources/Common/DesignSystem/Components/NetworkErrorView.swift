import SwiftUI

public struct NetworkErrorView: View {
    private let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(AppColors.warning)

            Text(message)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.onAccent)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.brandDarkBlue)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview("Network Error Light") {
    NetworkErrorView(message: "You're offline — reconnect to continue.")
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.light)
}

#Preview("Network Error Dark") {
    NetworkErrorView(message: "You're offline — reconnect to continue.")
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}
