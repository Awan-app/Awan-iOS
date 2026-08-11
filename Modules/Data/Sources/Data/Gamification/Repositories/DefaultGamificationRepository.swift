import AwaNetwork
import Domain

public final class DefaultGamificationRepository: GamificationRepository {
    private let remoteDataSource: any RemoteGamificationDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource

    public init(
        remoteDataSource: any RemoteGamificationDataSource,
        localProfileDataSource: any LocalUserProfileDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localProfileDataSource = localProfileDataSource
    }

    public func fetchWheelConfig() async throws -> DailyWheelConfiguration {
        do {
            return try DailyWheelMapper.configuration(
                await remoteDataSource.getWheelConfig()
            )
        } catch {
            throw map(error)
        }
    }

    public func spinWheel() async throws -> DailyWheelSpinResult {
        do {
            let result = try DailyWheelMapper.spinResult(
                await remoteDataSource.spinWheel()
            )

            // The reward is already committed remotely. Cache synchronization
            // must never turn that success into a retryable spin failure.
            try? await localProfileDataSource.updatePoints(result.newBalance)
            return result
        } catch {
            throw map(error)
        }
    }

    public func fetchActivityDays(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay> {
        do {
            let calendar = ActivityDayMapper.gregorianCalendar

            let requestedStart = try ActivityDayMapper.date(from: startDay)
            let requestedEnd = try ActivityDayMapper.date(from: endDay)

            guard requestedStart <= requestedEnd else {
                throw GamificationError.invalidActivityRange
            }

            guard let dayDifference = calendar.dateComponents(
                [.day],
                from: requestedStart,
                to: requestedEnd
            ).day else {
                throw GamificationError.invalidActivityRange
            }

            let inclusiveDayCount = dayDifference + 1

            guard inclusiveDayCount <= 31 else {
                throw GamificationError.invalidActivityRange
            }

            let response = try await remoteDataSource.getActivityDates(
                startDate: ActivityDayMapper.string(from: startDay),
                endDate: ActivityDayMapper.string(from: endDay)
            )

            return try ActivityDayMapper.map(response)

        } catch {
            throw map(error)
        }
    }

    private func map(_ error: any Error) -> any Error {
        if error is CancellationError {
            return CancellationError()
        }

        if let error = error as? GamificationError {
            return error
        }

        guard case let NetworkError.httpError(statusCode, apiError) = error else {
            return GamificationError.unavailable(error.localizedDescription)
        }

        if statusCode == 409,
           apiError?.errorCode == .dailyGiftAlreadyClaimed {
            return GamificationError.alreadyClaimed
        }

        switch apiError?.errorCode {
        case .userNotFound:
            return GamificationError.userNotFound
        case .refreshTokenInvalid, .refreshTokenExpired, .refreshTokenReuseDetected:
            return GamificationError.authenticationFailed
        default:
            return GamificationError.unavailable(
                apiError?.message ?? error.localizedDescription
            )
        }
    }
}
