import SwiftUI
import Kingfisher

public struct AppRemoteImage<Placeholder: View>: View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let placeholder: () -> Placeholder

    @State private var isFailed = false

    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    public init(
        urlString: String?,
        contentMode: SwiftUI.ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(
            url: urlString.flatMap(URL.init(string:)),
            contentMode: contentMode,
            placeholder: placeholder
        )
    }

    public var body: some View {
        if let url, !isFailed {
            KFImage(url)
                .onFailure { _ in
                    Task { @MainActor in
                        isFailed = true
                    }
                }
                .placeholder {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            placeholder()
        }
    }
}

#Preview("App Remote Image Light") {
    AppRemoteImage(urlString: nil as String?) {
        Image(systemName: "photo")
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(AppColors.textSecondary)
    }
    .frame(width: 120, height: 120)
    .background(AppColors.surface)
    .preferredColorScheme(.light)
}

#Preview("App Remote Image Dark") {
    AppRemoteImage(urlString: nil as String?) {
        Image(systemName: "photo")
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(AppColors.textSecondary)
    }
    .frame(width: 120, height: 120)
    .background(AppColors.surface)
    .preferredColorScheme(.dark)
}
