public struct OnboardingRequestDTO: Encodable, Sendable {
    public let firstName: String
    public let lastName: String
    public let birthDate: String
    public let timezone: String
    public let preferredSessionDuration: Int
    public let bufferBetweenSessions: Int
    public let wakeupTime: String
    public let sleepTime: String

    public init(
        firstName: String,
        lastName: String,
        birthDate: String,
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupTime: String,
        sleepTime: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
    }
}
