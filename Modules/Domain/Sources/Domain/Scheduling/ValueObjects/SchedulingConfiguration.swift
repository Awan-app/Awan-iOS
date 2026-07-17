public struct SchedulingConfiguration: Hashable, Sendable {
    public static let standard = SchedulingConfiguration(
        minimumSessionMinutes: 15,
        futureSearchDayLimit: 14,
        validated: ()
    )

    public let minimumSessionMinutes: Int
    public let futureSearchDayLimit: Int

    public init(minimumSessionMinutes: Int, futureSearchDayLimit: Int) throws {
        guard minimumSessionMinutes > 0, futureSearchDayLimit > 0 else {
            throw SchedulingError.invalidConfiguration
        }

        self.minimumSessionMinutes = minimumSessionMinutes
        self.futureSearchDayLimit = futureSearchDayLimit
    }

    private init(
        minimumSessionMinutes: Int,
        futureSearchDayLimit: Int,
        validated: Void
    ) {
        self.minimumSessionMinutes = minimumSessionMinutes
        self.futureSearchDayLimit = futureSearchDayLimit
    }
}
