import Domain
import Observation

enum MCPConnectionState: Equatable {
    case idle
    case loading
    case content(MCPConnectionDetails)
    case failure
}

@MainActor
@Observable
public final class MCPConnectionViewModel {
    private(set) var state: MCPConnectionState = .idle

    private let fetchConnectionDetailsUseCase: any FetchMCPConnectionDetailsUseCase

    public init(fetchConnectionDetailsUseCase: any FetchMCPConnectionDetailsUseCase) {
        self.fetchConnectionDetailsUseCase = fetchConnectionDetailsUseCase
    }

    func load() async {
        guard state != .loading else { return }
        state = .loading

        do {
            let details = try await fetchConnectionDetailsUseCase.execute()
            state = .content(details)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failure
        }
    }
}
