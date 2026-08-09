import Domain
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
    private(set) var isLoggingOut = false
    var showLogoutConfirmation = false
    var showLogoutError = false

    private let getUserProfileUseCase: GetUserProfileUseCase
    private let logoutUseCase: LogoutUseCase

    public init(
        getUserProfileUseCase: GetUserProfileUseCase,
        logoutUseCase: LogoutUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
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
            userName = [profile.firstName, profile.lastName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            userEmail = profile.email
            points = profile.points
            streak = profile.streak
            maxStreak = profile.maxStreak
            loadState = .content
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
}
