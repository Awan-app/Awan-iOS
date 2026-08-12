import Common
import SwiftUI

struct MarketplaceFilterSheet: View {
    let initialFilter: MarketplaceFilter
    let onApply: (MarketplaceFilter) -> Void
    let onReset: () -> Void

    @State private var localFilter: MarketplaceFilter = .default

    private let filterableCategories: [MarketplaceItemCategory] = [.frames, .skins, .themes, .appIcons]

    init(
        initialFilter: MarketplaceFilter,
        onApply: @escaping (MarketplaceFilter) -> Void,
        onReset: @escaping () -> Void
    ) {
        self.initialFilter = initialFilter
        self.onApply = onApply
        self.onReset = onReset
        _localFilter = State(initialValue: initialFilter)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 38, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 12)

            HStack(alignment: .firstTextBaseline) {
                Text(L10n.Marketplace.filtersTitle)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button {
                    withAnimation(.snappy(duration: 0.18)) {
                        localFilter = .default
                    }
                    onReset()
                } label: {
                    Text(L10n.Marketplace.filterReset)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.accentBlue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.Marketplace.filterItemType)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    HStack(spacing: 10) {
                        ForEach(filterableCategories) { category in
                            itemTypeCell(category)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.Marketplace.filterOwnership)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    Toggle(isOn: $localFilter.showsOnlyNotOwned) {
                        Text(L10n.Marketplace.filterNotOwnedOnly)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .tint(AppColors.accentBlue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColors.screenBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppColors.outline.opacity(0.12), lineWidth: 1)
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.Marketplace.filterPrice)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    RangeSlider(
                        minPrice: $localFilter.minPrice,
                        maxPrice: $localFilter.maxPrice,
                        bounds: 0...MarketplaceFilter.maxPtsCap
                    )

                    HStack {
                        priceLabel(Int(localFilter.minPrice), plusSuffix: false)
                        Spacer()
                        priceLabel(Int(localFilter.maxPrice), plusSuffix: localFilter.maxPrice >= MarketplaceFilter.maxPtsCap)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            AppButton(
                title: L10n.Marketplace.applyFilters,
                color: AppColors.accentBlue,
                size: .large,
                onTap: {
                    onApply(localFilter)
                }
            )
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 16)
        }
    }

    private func itemTypeCell(_ category: MarketplaceItemCategory) -> some View {
        let isSelected = localFilter.selectedCategories.contains(category)

        return Button {
            withAnimation(.snappy(duration: 0.18)) {
                if isSelected {
                    localFilter.selectedCategories.remove(category)
                } else {
                    localFilter.selectedCategories.insert(category)
                }
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                AppDepthSurface(
                    shape: .roundedRectangle(cornerRadius: 16),
                    surfaceColor: isSelected ? AppColors.surface : AppColors.surface.opacity(0.85),
                    borderColor: isSelected ? AppColors.accentBlue : AppColors.accentBlue.opacity(0.25),
                    depthColor: isSelected ? AppColors.accentBlueDepth : AppColors.accentBlueDepth.opacity(0.20),
                    borderWidth: 1.5,
                    depthOffset: isSelected ? 4 : 3,
                    contentInsets: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
                ) {
                    VStack(spacing: 6) {
                        Spacer(minLength: 0)
                        Image(categoryImage(category), bundle: .module)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .saturation(isSelected ? 1 : 0.55)
                            .opacity(isSelected ? 1 : 0.72)
                        Text(categoryTitle(category))
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }

                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.accentBlue : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected
                                        ? AppColors.accentBlue
                                        : AppColors.outline.opacity(0.40),
                                    lineWidth: 1.5
                                )
                        )
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(AppColors.onAccent)
                    }
                }
                .offset(x: 4, y: -4)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(categoryTitle(category))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func priceLabel(_ value: Int, plusSuffix: Bool) -> some View {
        AppDepthSurface(
            shape: .capsule,
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.14),
            depthColor: AppColors.outline.opacity(0.12),
            borderWidth: 1.5,
            depthOffset: 3,
            contentInsets: EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        ) {
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AppColors.reward)
                Text("\(value)\(plusSuffix ? "+" : "") \(L10n.Marketplace.pts)")
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    private func categoryTitle(_ category: MarketplaceItemCategory) -> String {
        switch category {
        case .frames:   return L10n.Marketplace.filterFrames
        case .skins:    return L10n.Marketplace.filterSkins
        case .themes:   return L10n.Marketplace.filterThemes
        case .appIcons: return L10n.Marketplace.filterAppIcons
        case .all:      return L10n.Marketplace.filterAll
        }
    }

    private func categoryImage(_ category: MarketplaceItemCategory) -> String {
        switch category {
        case .frames:   return "MarketplaceFilterFrame"
        case .skins:    return "MarketplaceFilterSkin"
        case .themes:   return "MarketplaceFilterTheme"
        case .appIcons: return "MarketplaceFilterAppIcon"
        case .all:      return "MarketplaceFilterAppIcon"
        }
    }
}

private struct RangeSlider: View {
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    let bounds: ClosedRange<Double>

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 22
    private let step: Double = 50

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let rangeSpan = bounds.upperBound - bounds.lowerBound
            let minFraction = (minPrice - bounds.lowerBound) / rangeSpan
            let maxFraction = (maxPrice - bounds.lowerBound) / rangeSpan

            let minX = minFraction * width
            let maxX = maxFraction * width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.accentBlue.opacity(0.18))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(AppColors.accentBlue)
                    .offset(x: minX)
                    .frame(width: max(0, maxX - minX), height: trackHeight)

                Circle()
                    .fill(AppColors.surface)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
                    .overlay(Circle().stroke(AppColors.accentBlue, lineWidth: 2))
                    .offset(x: max(0, minX - thumbSize / 2))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let rawVal = bounds.lowerBound + Double(value.location.x / width) * rangeSpan
                                let stepped = (rawVal / step).rounded() * step
                                let clamped = max(bounds.lowerBound, min(stepped, maxPrice))
                                minPrice = clamped
                            }
                    )

                Circle()
                    .fill(AppColors.surface)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
                    .overlay(Circle().stroke(AppColors.accentBlue, lineWidth: 2))
                    .offset(x: max(0, maxX - thumbSize / 2))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let rawVal = bounds.lowerBound + Double(value.location.x / width) * rangeSpan
                                let stepped = (rawVal / step).rounded() * step
                                let clamped = max(minPrice, min(stepped, bounds.upperBound))
                                maxPrice = clamped
                            }
                    )
            }
            .frame(height: thumbSize)
        }
        .frame(height: thumbSize)
    }
}

#Preview("Filter Sheet Light") {
    Color.gray.opacity(0.3).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MarketplaceFilterSheet(initialFilter: .default, onApply: { _ in }, onReset: {})
                .presentationDetents([.height(410), .large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(AppColors.surface)
        }
}
