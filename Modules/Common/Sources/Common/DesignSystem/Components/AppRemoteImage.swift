import Foundation
import Kingfisher
import SwiftUI

public struct AppRemoteImageRequestModifier: Sendable {
    fileprivate static let identity = AppRemoteImageRequestModifier { $0 }

    private let modifyRequest: @Sendable (URLRequest) -> URLRequest

    public init(_ modifyRequest: @escaping @Sendable (URLRequest) -> URLRequest) {
        self.modifyRequest = modifyRequest
    }

    fileprivate func modify(_ request: URLRequest) -> URLRequest {
        modifyRequest(request)
    }
}

private struct AppRemoteImageRequestModifierKey: EnvironmentKey {
    static let defaultValue = AppRemoteImageRequestModifier.identity
}

public extension EnvironmentValues {
    var appRemoteImageRequestModifier: AppRemoteImageRequestModifier {
        get { self[AppRemoteImageRequestModifierKey.self] }
        set { self[AppRemoteImageRequestModifierKey.self] = newValue }
    }
}

public struct AppRemoteImage<Placeholder: View>: View {
    @Environment(\.appRemoteImageRequestModifier) private var requestModifier

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
        let imageRequestModifier = requestModifier

        if let url, !isFailed {
            KFImage(url)
                .requestModifier { request in
                    request = imageRequestModifier.modify(request)
                }
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
