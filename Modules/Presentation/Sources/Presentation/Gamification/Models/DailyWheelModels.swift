import Domain

enum DailyWheelPhase: Equatable, Sendable {
    case idle
    case loading
    case ready
    case spinning
    case settling
    case claimed
    case failure
}

enum DailyWheelPresentation: Equatable, Sendable {
    case hidden
    case wheel
    case result(DailyWheelResultPresentation)
    case failure
}

enum DailyWheelResultPresentation: Equatable, Sendable {
    case spin(DailyWheelSpinResult)
}

enum DailyWheelRetryOperation: Equatable, Sendable {
    case load
    case spin
}

struct DailyWheelState: Equatable, Sendable {
    var phase: DailyWheelPhase = .idle
    var presentation: DailyWheelPresentation = .hidden
    var configuration: DailyWheelConfiguration?
    var pendingSpinResult: DailyWheelSpinResult?
    var errorMessage: String?
    var retryOperation: DailyWheelRetryOperation = .load
    var showsGiftButton = false
}

enum DailyWheelAction: Sendable {
    case mainFlowAppeared
    case openRequested
    case spinTapped
    case spinAnimationCompleted
    case dismissWheel
    case dismissResult
    case retry
    case closeFailure
    case sessionEnded
}

public struct DailyWheelUseCases: Sendable {
    public let fetch: any FetchDailyWheelUseCase
    public let spin: any SpinDailyWheelUseCase

    public init(
        fetch: any FetchDailyWheelUseCase,
        spin: any SpinDailyWheelUseCase
    ) {
        self.fetch = fetch
        self.spin = spin
    }
}
