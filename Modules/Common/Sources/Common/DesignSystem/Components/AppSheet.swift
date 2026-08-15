import SwiftUI

public enum AppSheetSizing: Hashable {
    case content(initialHeight: CGFloat = 320, maximumHeight: CGFloat = 700)
    case height(CGFloat)
    case medium
    case large
    case detents(Set<PresentationDetent>)
}

public struct AppSheet<Content: View>: View {
    private let sizing: AppSheetSizing
    private let animation: Animation
    private let dragIndicator: Visibility
    private let backgroundColor: Color
    private let content: Content

    @State private var contentHeight: CGFloat

    public init(
        sizing: AppSheetSizing = .content(),
        animation: Animation = .smooth(duration: 0.35),
        dragIndicator: Visibility = .visible,
        backgroundColor: Color = AppColors.sheetBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.sizing = sizing
        self.animation = animation
        self.dragIndicator = dragIndicator
        self.backgroundColor = backgroundColor
        self.content = content()

        let resolvedInitialHeight: CGFloat
        switch sizing {
        case .content(let initialHeight, let maximumHeight):
            resolvedInitialHeight = min(initialHeight, maximumHeight)
        case .height(let height):
            resolvedInitialHeight = height
        case .medium, .large, .detents:
            resolvedInitialHeight = 1
        }
        _contentHeight = State(initialValue: resolvedInitialHeight)
    }

    public var body: some View {
        Group {
            switch sizing {
            case .content(_, let maximumHeight):
                content
                    .fixedSize(horizontal: false, vertical: true)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        min(proxy.size.height, maximumHeight)
                    } action: { newHeight in
                        guard abs(newHeight - contentHeight) > 0.5 else { return }

                        withAnimation(animation) {
                            contentHeight = newHeight
                        }
                    }
                    .modifier(AppSheetHeightModifier(height: contentHeight))
            case .height(let height):
                content.presentationDetents([.height(height)])
            case .medium:
                content.presentationDetents([.medium])
            case .large:
                content.presentationDetents([.large])
            case .detents(let detents):
                content.presentationDetents(detents)
            }
        }
        .presentationDragIndicator(dragIndicator)
        .presentationBackground(backgroundColor)
    }
}

private struct AppSheetHeightModifier: ViewModifier, @preconcurrency Animatable {
    var height: CGFloat

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.presentationDetents([.height(height)])
    }
}

#Preview("Dynamic Sheet Light") {
    AppSheetPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dynamic Sheet Dark") {
    AppSheetPreviewHost()
        .preferredColorScheme(.dark)
}

private struct AppSheetPreviewHost: View {
    @State private var isPresented = true

    var body: some View {
        AppColors.screenBackground
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                AppSheet {
                    VStack(spacing: 16) {
                        Text("Reusable Sheet")
                            .font(AppFonts.title3Black)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("The detent follows the content height.")
                            .font(AppFonts.bodySemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(AppColors.sheetBackground)
                }
            }
    }
}
