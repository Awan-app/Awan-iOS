import Combine
import Domain
import Foundation
import Observation

enum ProfileLoadState: Equatable {
    case idle
    case loading
    case content
    case failure
}

@MainActor
@Observable
public final class ProfileViewModel {
    private(set) var loadState: ProfileLoadState = .idle
    private(set) var userName = ""
    private(set) var userEmail = ""
    private(set) var points = 0
    private(set) var streak = 0
    private(set) var maxStreak = 0
    private(set) var dailyZones: [Zone] = []
    private(set) var areDailyZonesReady = false
    private(set) var isLoggingOut = false
    var showLogoutConfirmation = false
    var showLogoutError = false

    private let getUserProfileUseCase: GetUserProfileUseCase
    private let fetchZonesUseCase: FetchZonesUseCase
    private let logoutUseCase: LogoutUseCase
    @ObservationIgnored private var zonesCancellable: AnyCancellable?
    @ObservationIgnored private var profileCancellable: AnyCancellable?

    public init(
        getUserProfileUseCase: GetUserProfileUseCase,
        fetchZonesUseCase: FetchZonesUseCase,
        logoutUseCase: LogoutUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.fetchZonesUseCase = fetchZonesUseCase
        self.logoutUseCase = logoutUseCase
    }

    public func load() async {
        guard loadState != .loading else { return }
        let hadContent = loadState == .content
        if !hadContent {
            loadState = .loading
        }

        do {
            let profile = try await getUserProfileUseCase.execute()
            updateProfileState(with: profile)
            observeUserProfile()
            observeDailyZones()
        } catch is CancellationError {
            return
        } catch {
            if !hadContent {
                loadState = .failure
            }
        }
    }

    func logout() async {
        guard !isLoggingOut else { return }
        isLoggingOut = true

        do {
            try await logoutUseCase.execute()
        } catch is CancellationError {
            isLoggingOut = false
            return
        } catch {
            showLogoutError = true
        }

        isLoggingOut = false
    }

    private func observeUserProfile() {
        profileCancellable?.cancel()
        profileCancellable = getUserProfileUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure = completion, self.loadState != .content {
                        self.loadState = .failure
                    }
                },
                receiveValue: { [weak self] profile in
                    guard let self else { return }
                    self.updateProfileState(with: profile)
                }
            )
    }

    private func updateProfileState(with profile: UserProfile) {
        userName = [profile.firstName, profile.lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        userEmail = profile.email
        points = profile.points
        streak = profile.streak
        maxStreak = profile.maxStreak
        loadState = .content
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
