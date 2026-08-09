import Combine
import Domain
import Foundation
import Observation

enum SettingsLoadState: Equatable {
    case idle
    case loading
    case content
    case failure
}

enum SettingsMutation: Equatable {
    case sessionDuration
    case timeZone
    case sleepSchedule
}

@MainActor
@Observable
public final class SettingsViewModel {
    private(set) var loadState: SettingsLoadState = .idle
    private(set) var activeMutation: SettingsMutation?
    private(set) var sessionTime = 0
    private(set) var timeZone = ""
    private(set) var wakeupTime: LocalTime?
    private(set) var sleepTime: LocalTime?
    private(set) var dailyZones: [Zone] = []
    private(set) var areDailyZonesReady = false
    var showError = false

    private let getUserProfileUseCase: GetUserProfileUseCase
    private let updateSessionDurationUseCase: any UpdateSessionDurationUseCase
    private let updateTimezoneUseCase: any UpdateTimezoneUseCase
    private let updateSleepScheduleUseCase: any UpdateSleepScheduleUseCase
    private let fetchZonesUseCase: FetchZonesUseCase
    @ObservationIgnored private var zonesCancellable: AnyCancellable?

    public init(
        getUserProfileUseCase: GetUserProfileUseCase,
        updateSessionDurationUseCase: any UpdateSessionDurationUseCase,
        updateTimezoneUseCase: any UpdateTimezoneUseCase,
        updateSleepScheduleUseCase: any UpdateSleepScheduleUseCase,
        fetchZonesUseCase: FetchZonesUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateSessionDurationUseCase = updateSessionDurationUseCase
        self.updateTimezoneUseCase = updateTimezoneUseCase
        self.updateSleepScheduleUseCase = updateSleepScheduleUseCase
        self.fetchZonesUseCase = fetchZonesUseCase
    }

    func load() async {
        guard loadState != .loading else { return }
        let hadContent = loadState == .content
        if !hadContent {
            loadState = .loading
        }

        do {
            apply(try await getUserProfileUseCase.execute())
            loadState = .content
            observeDailyZones()
        } catch is CancellationError {
            return
        } catch {
            if !hadContent {
                loadState = .failure
            }
        }
    }

    func updateSessionTime(_ duration: Int) async -> Bool {
        await perform(.sessionDuration) {
            try await updateSessionDurationUseCase.execute(duration)
        }
    }

    func updateTimeZone(_ identifier: String) async -> Bool {
        await perform(.timeZone) {
            try await updateTimezoneUseCase.execute(identifier)
        }
    }

    func updateSleepSchedule(wakeupTime: String, sleepTime: String) async -> Bool {
        await perform(.sleepSchedule) {
            try await updateSleepScheduleUseCase.execute(
                wakeUpTime: wakeupTime,
                sleepTime: sleepTime
            )
        }
    }

    private func perform(
        _ mutation: SettingsMutation,
        operation: () async throws -> UserProfile
    ) async -> Bool {
        guard activeMutation == nil else { return false }
        activeMutation = mutation

        do {
            apply(try await operation())
            activeMutation = nil
            return true
        } catch is CancellationError {
            activeMutation = nil
            return false
        } catch {
            activeMutation = nil
            showError = true
            return false
        }
    }

    private func apply(_ profile: UserProfile) {
        sessionTime = profile.preferences.preferredSessionDuration
        timeZone = profile.preferences.timezone
        wakeupTime = profile.preferences.wakeupTime
        sleepTime = profile.preferences.sleepTime
    }

    private func observeDailyZones() {
        zonesCancellable?.cancel()
        areDailyZonesReady = false
        zonesCancellable = fetchZonesUseCase.observe(for: Date())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] zones in
                    self?.dailyZones = zones
                    self?.areDailyZonesReady = true
                }
            )
    }
}
