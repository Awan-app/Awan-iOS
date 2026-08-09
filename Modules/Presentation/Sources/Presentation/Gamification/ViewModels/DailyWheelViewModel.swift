import Common
import Domain
import Observation

@Observable
@MainActor
public final class DailyWheelViewModel {
    private(set) var state = DailyWheelState()

    @ObservationIgnored private let useCases: DailyWheelUseCases
    @ObservationIgnored private var hasCheckedThisSession = false
    @ObservationIgnored private var operationTask: Task<Void, Never>?

    public init(useCases: DailyWheelUseCases) {
        self.useCases = useCases
    }

    deinit {
        operationTask?.cancel()
    }

    func send(_ action: DailyWheelAction) {
        switch action {
        case .mainFlowAppeared:
            guard !hasCheckedThisSession else { return }
            hasCheckedThisSession = true
            loadConfiguration(presentAutomatically: false)

        case .openRequested:
            switch state.phase {
            case .loading:
                loadConfiguration(presentAutomatically: true)
            case .spinning, .settling:
                state.presentation = .wheel
                state.showsGiftButton = false
            case .claimed:
                state.presentation = .wheel
                state.showsGiftButton = false
            case .failure:
                state.presentation = .failure
                state.showsGiftButton = false
            case .ready:
                state.phase = .ready
                state.presentation = .wheel
                state.showsGiftButton = false
            case .idle:
                loadConfiguration(presentAutomatically: true)
            }

        case .spinTapped:
            spin()

        case .spinAnimationCompleted:
            guard let result = state.pendingSpinResult else { return }
            state.pendingSpinResult = nil
            state.phase = .claimed
            state.presentation = .result(.spin(result))
            state.showsGiftButton = false

        case .dismissWheel:
            guard state.phase == .loading
                    || state.phase == .ready
                    || state.phase == .claimed else {
                return
            }
            if state.phase == .loading {
                operationTask?.cancel()
                state.phase = .idle
            }
            state.presentation = .hidden
            state.showsGiftButton = state.phase != .claimed

        case .dismissResult:
            state.presentation = .hidden

        case .retry:
            switch state.retryOperation {
            case .load:
                loadConfiguration(presentAutomatically: true)
            case .spin:
                spin()
            }

        case .closeFailure:
            operationTask?.cancel()
            state.presentation = .hidden
            state.showsGiftButton = true

        case .sessionEnded:
            operationTask?.cancel()
            hasCheckedThisSession = false
            state = DailyWheelState()
        }
    }

    private func loadConfiguration(presentAutomatically: Bool) {
        operationTask?.cancel()
        state.phase = .loading
        state.presentation = presentAutomatically ? .wheel : .hidden
        state.errorMessage = nil
        state.showsGiftButton = false

        operationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let configuration = try await useCases.fetch.execute()
                guard !Task.isCancelled else { return }

                state.configuration = configuration
                if configuration.claimedToday {
                    state.phase = .claimed
                    state.presentation = presentAutomatically ? .wheel : .hidden
                    state.showsGiftButton = false
                } else {
                    state.phase = .ready
                    state.presentation = presentAutomatically ? .wheel : .hidden
                    state.showsGiftButton = !presentAutomatically
                }
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                if presentAutomatically {
                    showFailure(error, retry: .load)
                } else {
                    state.phase = .failure
                    state.presentation = .hidden
                    state.errorMessage = GamificationErrorMessageMapper.message(for: error)
                    state.retryOperation = .load
                    state.showsGiftButton = true
                }
            }
        }
    }

    private func spin() {
        guard state.phase == .ready || state.phase == .failure,
              let configuration = state.configuration,
              !configuration.claimedToday else {
            return
        }

        operationTask?.cancel()
        state.phase = .spinning
        state.presentation = .wheel
        state.errorMessage = nil
        state.showsGiftButton = false

        operationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await useCases.spin.execute()
                guard !Task.isCancelled else { return }

                guard configuration.segments.contains(where: { $0.id == result.segmentID }) else {
                    showFailure(
                        GamificationError.invalidWheelConfiguration,
                        retry: .load
                    )
                    return
                }

                state.pendingSpinResult = result
                state.phase = .settling
            } catch is CancellationError {
                return
            } catch GamificationError.alreadyClaimed {
                await recoverAlreadyClaimed()
            } catch {
                guard !Task.isCancelled else { return }
                showFailure(error, retry: .spin)
            }
        }
    }

    private func recoverAlreadyClaimed() async {
        do {
            let configuration = try await useCases.fetch.execute()
            guard !Task.isCancelled else { return }
            state.configuration = configuration
        } catch {
            // Keep the existing segment layout so the claimed state can still
            // be represented without risking another spin.
        }
        state.phase = .claimed
        state.presentation = .wheel
        state.showsGiftButton = false
    }

    private func showFailure(
        _ error: any Error,
        retry: DailyWheelRetryOperation
    ) {
        state.phase = .failure
        state.presentation = .failure
        state.errorMessage = GamificationErrorMessageMapper.message(for: error)
        state.retryOperation = retry
        state.showsGiftButton = false
    }
}
