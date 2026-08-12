import SwiftUI

public struct AppRemoteImage<Placeholder: View>: View {
    private let url: URL?
    private let contentMode: ContentMode
    private let placeholder: () -> Placeholder

    public init(
        url: URL?,
        contentMode: ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    public init(
        urlString: String?,
        contentMode: ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(
            url: urlString.flatMap(URL.init(string:)),
            contentMode: contentMode,
            placeholder: placeholder
        )
    }

    public var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure:
                    placeholder()
                @unknown default:
                    placeholder()
                }
            }
        } else {
            placeholder()
        }
    }
}

#Preview("App Remote Image Light") {
    AppRemoteImage(urlString: nil) {
        Image(systemName: "photo")
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(AppColors.textSecondary)
    }
    .frame(width: 120, height: 120)
    .background(AppColors.surface)
    .preferredColorScheme(.light)
}

#Preview("App Remote Image Dark") {
    AppRemoteImage(urlString: nil) {
        Image(systemName: "photo")
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(AppColors.textSecondary)
    }
    .frame(width: 120, height: 120)
    .background(AppColors.surface)
    .preferredColorScheme(.dark)
}
