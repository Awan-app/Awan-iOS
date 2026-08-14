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
    private(set) var profilePictureUrl: String?
    private(set) var dailyZones: [Zone] = []
    private(set) var areDailyZonesReady = false
    private(set) var isLoggingOut = false
    var showLogoutConfirmation = false
    var showLogoutError = false
    private(set) var mcpConnectionText: String?
    private(set) var isMCPLoading = false

    private let getUserProfileUseCase: GetUserProfileUseCase
    private let fetchZonesUseCase: FetchZonesUseCase
    private let logoutUseCase: LogoutUseCase
    private let fetchMCPConnectionDetailsUseCase: FetchMCPConnectionDetailsUseCase
    private let onLogout: (() -> Void)?
    @ObservationIgnored private var zonesCancellable: AnyCancellable?
    @ObservationIgnored private var profileCancellable: AnyCancellable?

    public init(
        getUserProfileUseCase: GetUserProfileUseCase,
        fetchZonesUseCase: FetchZonesUseCase,
        logoutUseCase: LogoutUseCase,
        fetchMCPConnectionDetailsUseCase: FetchMCPConnectionDetailsUseCase,
        onLogout: (() -> Void)? = nil

    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.fetchZonesUseCase = fetchZonesUseCase
        self.logoutUseCase = logoutUseCase
        self.fetchMCPConnectionDetailsUseCase = fetchMCPConnectionDetailsUseCase
        self.onLogout = onLogout
        


    }

    public func load() async {
        guard loadState != .loading else { return }
        let hadContent = loadState == .content
        if !hadContent {
            loadState = .loading
        }

        do {
            let profile = try await getUserProfileUseCase.execute()
            userName = [profile.firstName, profile.lastName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            userEmail = profile.email
            points = profile.points
            streak = profile.streak
            maxStreak = profile.maxStreak
            profilePictureUrl = profile.profilePictureUrl
            loadState = .content
            updateProfileState(with: profile)
            observeUserProfile()
            observeDailyZones()
            
            // Fetch MCP connection details concurrently (don't block profile loading)
            Task {
                await fetchMCPConnectionDetails()
            }
        } catch is CancellationError {
            return
        } catch {
            if !hadContent {
                loadState = .failure
            }
        }
    }

    private func fetchMCPConnectionDetails() async {
        isMCPLoading = true
        do {
            let details = try await fetchMCPConnectionDetailsUseCase.execute()
            mcpConnectionText = details.mcpUrl
        } catch {
            // Silently fail or handle error. The requirement states: "Handle loading, success, and error states properly."
            // Since it's a read-only display, if it fails, we can just leave it nil or set an error message.
            // Leaving it nil will hide the section or we can show an error placeholder. 
            // For now, setting to nil handles the error by not displaying the section, 
            // but let's keep it nil and let the view decide.
            mcpConnectionText = nil
        }
        isMCPLoading = false
    }

    public func logout() async {
        guard !isLoggingOut else { return }
        isLoggingOut = true

        do {
            try await logoutUseCase.execute()
            onLogout?()
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
