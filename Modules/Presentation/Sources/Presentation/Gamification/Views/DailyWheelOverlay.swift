import Common
import Domain
import SwiftUI

struct DailyWheelOverlay: View {
    @State private var viewModel: DailyWheelViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var restingRotation = 0.0
    @State private var spinStart: Date?
    @State private var spinBaseRotation = 0.0

    init(viewModel: DailyWheelViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColors.shadow
                .opacity(0.82)
                .ignoresSafeArea()

            if let configuration = viewModel.state.configuration {
                wheelContent(configuration)
            } else {
                loadingContent
            }

            if canDismiss {
                closeButton
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .task(id: viewModel.state.phase) {
            switch viewModel.state.phase {
            case .spinning:
                spinBaseRotation = restingRotation
                spinStart = .now
            case .settling:
                await settleOnBackendResult()
            default:
                break
            }
        }
    }

    private var canDismiss: Bool {
        viewModel.state.phase == .loading || viewModel.state.phase == .ready
    }

    private var closeButton: some View {
        Button {
            viewModel.send(.dismissWheel)
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(AppColors.brandDarkBlue)
                .frame(width: 42, height: 42)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .circle,
                surfaceColor: AppColors.surface,
                borderColor: AppColors.onAccent.opacity(0.62),
                depthColor: AppColors.outline.opacity(0.48),
                borderWidth: 1.5,
                depthOffset: 4,
                pressedOffset: 3
            )
        )
        .accessibilityLabel(L10n.Common.close)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .safeAreaPadding(.top, 10)
        .padding(.trailing, 18)
    }

    private func wheelContent(
        _ configuration: DailyWheelConfiguration
    ) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(L10n.DailyWheel.title)
                    .font(AppFonts.titleBlack)
                    .foregroundStyle(AppColors.onAccent)

                Text(L10n.DailyWheel.subtitle)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.onAccent.opacity(0.78))
                    .multilineTextAlignment(.center)
            }

            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                DailyWheelDisc(
                    segments: configuration.segments,
                    rotation: rotation(at: timeline.date),
                    isSpinning: viewModel.state.phase == .spinning
                )
            }
            .frame(maxWidth: 360)
            .aspectRatio(1, contentMode: .fit)

            VStack(spacing: 8) {
                Text(promptText)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.onAccent)
                    .multilineTextAlignment(.center)

                if viewModel.state.phase == .spinning
                    || viewModel.state.phase == .settling {
                    ProgressView()
                        .tint(AppColors.reward)
                }
            }
        }
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .onTapGesture {
            guard viewModel.state.phase == .ready else { return }
            viewModel.send(.spinTapped)
        }
        .accessibilityAction(named: Text(L10n.DailyWheel.spin)) {
            guard viewModel.state.phase == .ready else { return }
            viewModel.send(.spinTapped)
        }
    }

    private var loadingContent: some View {
        VStack(spacing: 18) {
            Image(systemName: "gift.fill")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.reward)
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.onAccent)
            Text(L10n.DailyWheel.loading)
                .font(AppFonts.bodyBold)
                .foregroundStyle(AppColors.onAccent)
        }
    }

    private var promptText: String {
        switch viewModel.state.phase {
        case .ready:
            L10n.DailyWheel.tapToSpin
        case .spinning:
            L10n.DailyWheel.choosingReward
        case .settling:
            L10n.DailyWheel.almostThere
        default:
            L10n.DailyWheel.tapToSpin
        }
    }

    private func rotation(at date: Date) -> Double {
        guard !reduceMotion,
              viewModel.state.phase == .spinning,
              let spinStart else {
            return restingRotation
        }
        return spinBaseRotation + date.timeIntervalSince(spinStart) * 420
    }

    @MainActor
    private func settleOnBackendResult() async {
        guard let result = viewModel.state.pendingSpinResult,
              let segments = viewModel.state.configuration?.segments,
              let index = segments.firstIndex(where: { $0.id == result.segmentID }),
              !segments.isEmpty else {
            return
        }

        let currentRotation: Double
        if !reduceMotion, let spinStart {
            currentRotation = spinBaseRotation
                + Date.now.timeIntervalSince(spinStart) * 420
        } else {
            currentRotation = restingRotation
        }

        restingRotation = currentRotation
        let segmentAngle = 360.0 / Double(segments.count)
        let desired = -(Double(index) + 0.5) * segmentAngle
        let normalized = currentRotation.truncatingRemainder(dividingBy: 360)
        let correction = (desired - normalized + 720)
            .truncatingRemainder(dividingBy: 360)
        let settlingDuration = reduceMotion ? 0.55 : 5.4
        let revealDelay = reduceMotion ? 0.25 : 0.9
        let extraTurns = reduceMotion ? 0.0 : 7.0 * 360

        withAnimation(
            .timingCurve(
                0.16,
                0.68,
                0.10,
                1,
                duration: settlingDuration
            )
        ) {
            restingRotation = currentRotation + extraTurns + correction
        }

        try? await Task.sleep(for: .seconds(settlingDuration))
        guard !Task.isCancelled else { return }

        // Let the selected wedge sit under the pointer for an anticipation beat
        // before covering the wheel with the reward celebration.
        try? await Task.sleep(for: .seconds(revealDelay))
        guard !Task.isCancelled else { return }
        viewModel.send(.spinAnimationCompleted)
    }
}
