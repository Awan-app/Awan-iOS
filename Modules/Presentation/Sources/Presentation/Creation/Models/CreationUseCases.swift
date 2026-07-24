import Domain

public struct CreationUseCases: Sendable {
    public let fetchZones: any FetchZonesUseCase
    public let createTask: any CreateTaskUseCase
    public let createTaskWithAwan: any CreateTaskWithAwanUseCase
    public let userProfile: any GetUserProfileUseCase

    public init(
        fetchZones: any FetchZonesUseCase,
        createTask: any CreateTaskUseCase,
        createTaskWithAwan: any CreateTaskWithAwanUseCase,
        userProfile: any GetUserProfileUseCase
    ) {
        self.fetchZones = fetchZones
        self.createTask = createTask
        self.createTaskWithAwan = createTaskWithAwan
        self.userProfile = userProfile
    }
}
