import Domain
import Foundation

enum RemoteDomainMappingError: Error, LocalizedError {
    case missingField(String)
    case invalidValue(String)

    var errorDescription: String? {
        switch self {
        case .missingField(let field):
            return "Missing required field: \(field)"
        case .invalidValue(let detail):
            return "Invalid value: \(detail)"
        }
    }
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
        
        let mappedEquippedItems: [EquippedItem] = try dto.equippedItems?.map { eqDto in
            guard let equippedDate = try? parseISO8601Date(eqDto.equippedAt) else {
                throw RemoteDomainMappingError.invalidValue("equippedAt.\(eqDto.equippedAt)")
            }
            let storeItemType = StoreItemType(apiValue: eqDto.item.type)
            let storeItem = StoreItem(
                id: eqDto.item.id,
                name: eqDto.item.name,
                description: eqDto.item.description ?? "",
                image: GamificationImageURLMapper.string(from: eqDto.item.image),
                info: eqDto.item.info,
                price: eqDto.item.price,
                version: eqDto.item.version,
                type: storeItemType
            )
            return EquippedItem(type: StoreItemType(apiValue: eqDto.type), item: storeItem, equippedAt: equippedDate)
        } ?? []

        return UserProfile(
            id: dto.id,
            email: dto.email,
            firstName: firstName,
            lastName: lastName,
            birthDate: try parseBirthDate(birthDate),
            points: dto.points,
            streak: dto.streak,
            maxStreak: dto.maxStreak,
            profilePictureUrl: dto.profilePictureUrl,
            isNew: dto.isNew ?? false,
            preferences: UserPreferences(
                timezone: dto.preferences.timezone,
                preferredSessionDuration: dto.preferences.preferredSessionDuration,
                bufferBetweenSessions: dto.preferences.bufferBetweenSessions,
                wakeupTime: try parseTime(dto.preferences.wakeupTime),
                sleepTime: try parseTime(dto.preferences.sleepTime)
            ),
            equippedItems: mappedEquippedItems
        )
    }

    static func task(
        _ dto: TaskInfoResponseDTO,
        defaultDuration: Int
    ) throws -> AwanTask {
        try AwanTask(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            status: taskStatus(
                dto.status,
                completedAt: dto.completedAt
            ),
            completedAt: try dto.completedAt.map(parseISO8601Date),
            goalID: dto.goalID,
            duration: try TaskDuration(minutes: max(dto.estimatedDuration ?? defaultDuration, 1)),
            isSplittable: dto.isSplittable,
            mandatory: dto.mandatory,
            estimatedPoints: dto.estimatedPoints,
            dependencyIDs: Set(dto.dependencyIDs),
            category: dto.category.map {
                TaskCategory(id: $0.id, name: $0.name)
            }
        )
    }

    static func goal(_ dto: GoalInfoResponseDTO) throws -> Goal {
        let deadline: Date?
        if let targetDate = dto.targetDate {
            guard let parsedDeadline = LocalDateKey.date(from: targetDate) else {
                throw RemoteDomainMappingError.invalidValue(
                    "goal.targetDate.\(targetDate)"
                )
            }
            deadline = parsedDeadline
        } else {
            deadline = nil
        }

        return Goal(
            id: dto.id,
            name: dto.title,
            description: dto.description,
            status: try goalStatus(dto.status),
            deadline: deadline,
            createdAt: try parseISO8601Date(dto.createdAt)
        )
    }

    static func session(
        _ dto: SessionResponseDTO,
        timeZoneID: String
    ) throws -> Session {
        return Session(
            id: dto.id,
            taskID: dto.taskID,
            zoneID: dto.zoneId,
            timeRange: try TimeRange(
                start: parseDateTime(dto.start, timeZoneID: timeZoneID),
                end: parseDateTime(dto.end, timeZoneID: timeZoneID)
            ),
            blocking: dto.locked,
            status: try sessionStatus(dto.status),
            firstCompletedAt: try dto.firstCompletedAt.map(parseISO8601Date)
        )
    }

    static func zone(_ dto: ZoneResponseDTO) throws -> Zone {
        try Zone(
            id: dto.id,
            name: dto.name,
            color: ZoneColor(hex: dto.color ?? "#6C63FF"),
            startTime: parseTime(dto.startTime),
            endTime: parseTime(dto.endTime),
            category: TaskCategory(id: dto.category.id, name: dto.category.name)
        )
    }

    static func template(_ dto: TemplateResponseDTO) throws -> Template {
        let data = try templateData(dto)
        return Template(
            id: data.id,
            name: data.name,
            daysOfWeek: Set(try dto.daysOfWeek.map(templateWeekday)),
            zones: data.zones
        )
    }

    static func templateData(_ dto: TemplateResponseDTO) throws -> TemplateData {
        let weekDays = try Set(dto.daysOfWeek.map(weekDay))
        guard !weekDays.isEmpty else {
            throw RemoteDomainMappingError.missingField("template.daysOfWeek")
        }
        return TemplateData(
            id: dto.id,
            name: dto.name,
            weekDays: weekDays,
            zones: try dto.zones.map(zone)
        )
    }

    static func templateOverrideData(
        _ dto: TemplateOverrideResponseDTO
    ) throws -> TemplateOverrideData {
        guard let date = LocalDateKey.date(from: dto.dateOfDay),
              LocalDateKey.value(for: date, timeZoneID: "GMT") == dto.dateOfDay else {
            throw RemoteDomainMappingError.invalidValue(
                "templateOverride.dateOfDay.\(dto.dateOfDay)"
            )
        }
        return TemplateOverrideData(
            id: dto.id,
            name: dto.name ?? "Override",
            dateKey: dto.dateOfDay,
            dateOfDay: date,
            zones: try dto.zones.map(zone)
        )
    }

    static func templateOverride(
        _ dto: TemplateOverrideResponseDTO
    ) throws -> TemplateOverride {
        return TemplateOverride(
            id: dto.id,
            name: dto.name,
            dateOfDay: try TemplateOverrideDate(iso8601: dto.dateOfDay),
            zones: try dto.zones.map(zone)
        )
    }

    static func formatDateTime(_ date: Date, timeZoneID: String) -> String {
        dateTimeFormatter(timeZoneID: timeZoneID).string(from: date)
    }


    private static func taskStatus(
        _ raw: String,
        completedAt: String?
    ) throws -> TaskStatus {
        // If the task has a completion timestamp, it is always completed.
        if completedAt != nil {
            return .completed
        }

        return switch raw.uppercased() {
        case "DRAFTED", "DRAFT":
            .drafted

        case "ACTIVE", "IN_PROGRESS", "INPROGRESS", "DOING", "SCHEDULED", "PENDING", "TODO", "UNSCHEDULED", "PLANNED", "CREATED", "NEW", "NOT_STARTED":
            .active

        case "COMPLETED", "DONE", "FINISHED":
            .completed

        case "CANCELLED", "CANCELED", "ABORTED":
            .cancelled

        default:
            throw RemoteDomainMappingError.invalidValue("task.status.\(raw)")
        }
    }

    private static func goalStatus(_ raw: String) throws -> GoalStatus {
        switch raw.uppercased() {
        case "ACTIVE": .active
        case "COMPLETED": .completed
        case "CANCELLED": .cancelled
        default: throw RemoteDomainMappingError.invalidValue("goal.status.\(raw)")
        }
    }

    private static func weekDay(_ raw: String) throws -> Int {
        switch raw.uppercased() {
        case "SUNDAY": 1
        case "MONDAY": 2
        case "TUESDAY": 3
        case "WEDNESDAY": 4
        case "THURSDAY": 5
        case "FRIDAY": 6
        case "SATURDAY": 7
        default:
            throw RemoteDomainMappingError.invalidValue(
                "template.daysOfWeek.\(raw)"
            )
        }
    }

    private static func templateWeekday(_ raw: String) throws -> TemplateWeekday {
        guard let weekday = TemplateWeekday(rawValue: raw.uppercased()) else {
            throw RemoteDomainMappingError.invalidValue(
                "template.daysOfWeek.\(raw)"
            )
        }
        return weekday
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
        if let date = try? parseISO8601Date(value) {
            return date
        }
        guard let date = dateTimeFormatter(timeZoneID: timeZoneID).date(from: value) else {
            throw RemoteDomainMappingError.invalidValue("dateTime.\(value)")
        }
        return date
    }

    private static func parseISO8601Date(_ value: String) throws -> Date {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]
        if let date = fractionalFormatter.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let date = formatter.date(from: value) else {
            throw RemoteDomainMappingError.invalidValue(
                "goal.createdAt.\(value)"
            )
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
    static func completionReward(
        _ dto: CompletionRewardDTO
    ) -> CompletionReward {
        CompletionReward(
            points: .init(
                awarded: dto.points.awarded,
                amount: dto.points.amount,
                oldValue: dto.points.oldValue,
                newValue: dto.points.newValue
            ),
            streak: .init(
                updated: dto.streak.updated,
                oldValue: dto.streak.oldValue,
                newValue: dto.streak.newValue,
                maxStreakBroken: dto.streak.maxStreakBroken,
                maxStreakOld: dto.streak.maxStreakOld,
                maxStreakNew: dto.streak.maxStreakNew
            )
        )
    }
}
