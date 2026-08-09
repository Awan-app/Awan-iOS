import Common
import SwiftUI

struct DailyWheelPresentationLayer: View {
    let alwaysShowsFloatingButton: Bool
    @State private var viewModel: DailyWheelViewModel

    init(
        viewModel: DailyWheelViewModel,
        alwaysShowsFloatingButton: Bool
    ) {
        _viewModel = State(initialValue: viewModel)
        self.alwaysShowsFloatingButton = alwaysShowsFloatingButton
    }

    var body: some View {
        ZStack {
            if (alwaysShowsFloatingButton || viewModel.state.showsGiftButton),
               viewModel.state.presentation == .hidden {
                floatingButton
                    .transition(.scale.combined(with: .opacity))
            }

            switch viewModel.state.presentation {
            case .hidden:
                EmptyView()
            case .wheel:
                DailyWheelOverlay(viewModel: viewModel)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            case let .result(result):
                DailyWheelResultOverlay(result: result) {
                    viewModel.send(.dismissResult)
                }
                .transition(.scale(scale: 0.88).combined(with: .opacity))
            case .failure:
                DailyWheelFailureOverlay(
                    message: viewModel.state.errorMessage
                        ?? L10n.Common.pleaseTryAgain,
                    onRetry: { viewModel.send(.retry) },
                    onClose: { viewModel.send(.closeFailure) }
                )
                .transition(.opacity)
            }
        }
        .animation(
            .spring(response: 0.38, dampingFraction: 0.78),
            value: viewModel.state.presentation
        )
        .task {
            viewModel.send(.mainFlowAppeared)
        }
        .onDisappear {
            viewModel.send(.sessionEnded)
        }
    }

    private var floatingButton: some View {
        Button {
            viewModel.send(.openRequested)
        } label: {
            Image(systemName: "gift.fill")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(AppColors.onAccent)
                .frame(width: 56, height: 56)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .circle,
                surfaceColor: AppColors.reward,
                borderColor: AppColors.onAccent.opacity(0.48),
                depthColor: AppColors.wheelRimDepth,
                borderWidth: 2,
                depthOffset: 6,
                pressedOffset: 4
            )
        )
        .accessibilityLabel(L10n.DailyWheel.openGift)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding(.trailing, 8)
        .offset(y: 42)
    }
}
