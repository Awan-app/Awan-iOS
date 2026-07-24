import Domain
import Foundation

enum RemoteDomainMappingError: Error {
    case missingField(String)
    case invalidValue(String)
}

enum HomeRemoteMapper {
    static func profile(_ dto: UserProfileResponseDTO) throws -> UserProfile {
        guard let firstName = dto.firstName, !firstName.isEmpty else {
            throw RemoteDomainMappingError.missingField("firstName")
        }
        guard let lastName = dto.lastName, !lastName.isEmpty else {
            throw RemoteDomainMappingError.missingField("lastName")
        }
        guard let birthDate = dto.birthDate else {
            throw RemoteDomainMappingError.missingField("birthDate")
        }
        return UserProfile(
            id: dto.id,
            email: dto.email,
            firstName: firstName,
            lastName: lastName,
            birthDate: try parseBirthDate(birthDate),
            points: dto.points,
            streak: dto.streak,
            maxStreak: dto.maxStreak,
            preferences: UserPreferences(
                timezone: dto.preferences.timezone,
                preferredSessionDuration: dto.preferences.preferredSessionDuration,
                bufferBetweenSessions: dto.preferences.bufferBetweenSessions,
                wakeupTime: try parseTime(dto.preferences.wakeupTime),
                sleepTime: try parseTime(dto.preferences.sleepTime)
            )
        )
    }

    static func task(
        _ dto: TaskInfoResponseDTO,
        zoneID: UUID?,
        defaultDuration: Int
    ) throws -> AwanTask {
        try AwanTask(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            status: taskStatus(dto.status),
            goalID: dto.goalID,
            zoneID: zoneID,
            duration: TaskDuration(minutes: dto.estimatedDuration ?? defaultDuration),
            isSplittable: dto.isSplittable,
            mandatory: dto.mandatory,
            estimatedPoints: dto.estimatedPoints,
            dependencyIDs: Set(dto.dependencyIDs)
        )
    }

    static func session(
        _ dto: SessionResponseDTO,
        timeZoneID: String
    ) throws -> Session {
        Session(
            id: dto.id,
            taskID: dto.taskID,
            zoneID: dto.zoneId,
            timeRange: try TimeRange(
                start: parseDateTime(dto.start, timeZoneID: timeZoneID),
                end: parseDateTime(dto.end, timeZoneID: timeZoneID)
            ),
            blocking: dto.locked,
            status: try sessionStatus(dto.status)
        )
    }

    static func zone(_ dto: ZoneResponseDTO) throws -> Zone {
        try Zone(
            id: dto.id,
            name: dto.name,
            color: ZoneColor(hex: dto.color ?? "#6C63FF"),
            startTime: parseTime(dto.startTime),
            endTime: parseTime(dto.endTime)
        )
    }

    static func formatDateTime(_ date: Date, timeZoneID: String) -> String {
        dateTimeFormatter(timeZoneID: timeZoneID).string(from: date)
    }

    private static func taskStatus(_ raw: String) throws -> TaskStatus {
        switch raw.uppercased() {
        case "SCHEDULED", "PENDING": .pending
        case "IN_PROGRESS": .inProgress
        case "COMPLETED": .completed
        case "CANCELLED": .cancelled
        default: throw RemoteDomainMappingError.invalidValue("task.status.\(raw)")
        }
    }

    private static func sessionStatus(_ raw: String) throws -> Session.Status {
        switch raw.uppercased() {
        case "SCHEDULED", "IN_PROGRESS", "PLANNED": .planned
        case "COMPLETED": .completed
        case "SKIPPED", "MISSED": .missed
        case "CANCELLED": .cancelled
        default: throw RemoteDomainMappingError.invalidValue("session.status.\(raw)")
        }
    }

    private static func parseBirthDate(_ value: String) throws -> BirthDate {
        let parts = value.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            throw RemoteDomainMappingError.invalidValue("birthDate.\(value)")
        }
        return try BirthDate(year: year, month: month, day: day)
    }

    private static func parseTime(_ value: String) throws -> LocalTime {
        let parts = value.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            throw RemoteDomainMappingError.invalidValue("time.\(value)")
        }
        return try LocalTime(hour: hour, minute: minute)
    }

    private static func parseDateTime(_ value: String, timeZoneID: String) throws -> Date {
        guard let date = dateTimeFormatter(timeZoneID: timeZoneID).date(from: value) else {
            throw RemoteDomainMappingError.invalidValue("dateTime.\(value)")
        }
        return date
    }

    private static func dateTimeFormatter(timeZoneID: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
}
