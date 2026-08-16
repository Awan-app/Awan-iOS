import SwiftUI

public struct AppBackButton: View {
    private let accessibilityLabel: String
    private let onTap: () -> Void

    public init(
        accessibilityLabel: String,
        onTap: @escaping () -> Void
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Image(systemName: "chevron.backward")
                .font(AppFonts.bodyBold)
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(AppDepthButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

