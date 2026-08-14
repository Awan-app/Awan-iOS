import Common
import SwiftUI

struct MarketplaceItemArtwork: View {
    let imageURL: String?
    let category: MarketplaceItemCategory?
    let symbolName: String
    let placeholderImageName: String?

    init(
        imageURL: String?,
        category: MarketplaceItemCategory? = nil,
        symbolName: String,
        placeholderImageName: String? = nil
    ) {
        self.imageURL = imageURL
        self.category = category
        self.symbolName = symbolName
        self.placeholderImageName = placeholderImageName
    }

    var body: some View {
        AppRemoteImage(urlString: imageURL) {
            MarketplaceItemArtworkPlaceholder(
                category: category,
                symbolName: symbolName,
                imageName: placeholderImageName
            )
        }
    }
}

private struct MarketplaceItemArtworkPlaceholder: View {
    let category: MarketplaceItemCategory?
    let symbolName: String
    let imageName: String?

    var body: some View {
        Group {
            if let resolvedImageName = imageName ?? category?.placeholderImageName {
                Image(resolvedImageName, bundle: .module)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

private extension MarketplaceItemCategory {
    var placeholderImageName: String? {
        switch self {
        case .frames: return "MarketplaceFilterFrame"
        case .skins: return "MarketplaceFilterSkin"
        case .themes: return "MarketplaceFilterTheme"
        case .appIcons: return "MarketplaceFilterAppIcon"
        case .all: return nil
        }
    }
}
