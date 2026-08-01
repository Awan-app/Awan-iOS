import Common
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class DailyZonesViewModel: ZoneManaging {
    public var state: DailyZonesState = .idle
    public var isAddZoneSheetPresented: Bool = false
    public var editingZone: SuggestedZone?
    public var suggestedZones: [SuggestedZone] = []

    public var wakeupTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? .now
    public var sleepTime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? .now

    public var availableDays: [String] = []
    public var selectedDay: String?

    public var templates: [Template] = []
    public var selectedTemplateId: UUID?

    private let fetchTemplatesUseCase: any FetchTemplatesUseCase
    private let updateTemplateUseCase: any UpdateTemplateUseCase
    private let getUserProfileUseCase: any GetUserProfileUseCase
    private let manageDailyZoneScheduleUseCase: any ManageDailyZoneScheduleUseCase

    private var currentTemplate: Template?

    public init(
        fetchTemplatesUseCase: any FetchTemplatesUseCase,
        updateTemplateUseCase: any UpdateTemplateUseCase,
        getUserProfileUseCase: any GetUserProfileUseCase,
        manageDailyZoneScheduleUseCase: any ManageDailyZoneScheduleUseCase
    ) {
        self.fetchTemplatesUseCase = fetchTemplatesUseCase
        self.updateTemplateUseCase = updateTemplateUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.manageDailyZoneScheduleUseCase = manageDailyZoneScheduleUseCase
    }

    public func load() async {
        state = .loading

        do {
            async let profileTask = getUserProfileUseCase.execute()
            async let templatesTask = fetchTemplatesUseCase.execute()

            let (profile, fetchedTemplates) = try await (profileTask, templatesTask)

            self.templates = fetchedTemplates
            self.availableDays = Array(Set(fetchedTemplates.flatMap(\.daysOfWeek))).sorted(by: {
                dayValue($0) < dayValue($1)
            })
            let defaultTemplate = manageDailyZoneScheduleUseCase.defaultTemplate(from: fetchedTemplates)
            currentTemplate = defaultTemplate
            selectedTemplateId = defaultTemplate?.id
            wakeupTime = profile.preferences.wakeupTime.toDate() ?? wakeupTime
            sleepTime = profile.preferences.sleepTime.toDate() ?? sleepTime
            refreshZones()
            state = .content
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    public func selectDay(_ day: String) {
        self.selectedDay = day
        refreshZones()
    }

    public func selectTemplate(_ template: Template) {
        selectedTemplateId = template.id
        currentTemplate = template
        refreshZones()
    }

    public var availableHours: Int {
        manageDailyZoneScheduleUseCase.availableHours(wakeupTime: wakeupTime, sleepTime: sleepTime)
    }

    public var hasZoneOutsideActiveHours: Bool {
        manageDailyZoneScheduleUseCase.hasZoneOutsideActiveHours(
            suggestedZones.map(\.asDraft),
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    public func isZoneOutsideActiveHours(_ zone: SuggestedZone) -> Bool {
        manageDailyZoneScheduleUseCase.hasZoneOutsideActiveHours(
            [zone.asDraft],
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    public func removeZone(_ zone: SuggestedZone) {
        suggestedZones.removeAll { $0.id == zone.id }
    }

    public func addZone(_ zone: SuggestedZone) {
        let updated = manageDailyZoneScheduleUseCase.addingZone(
            zone.asDraft,
            to: suggestedZones.map(\.asDraft)
        )
        suggestedZones = updated.map(\.asSuggestedZone)
    }

    public func updateZone(
        id: UUID, name: String, colorRed: Double, colorGreen: Double, colorBlue: Double, startTime: String, endTime: String
    ) {
        let r = Int(round(colorRed * 255))
        let g = Int(round(colorGreen * 255))
        let b = Int(round(colorBlue * 255))
        let hex = String(format: "#%02X%02X%02X", r, g, b)
        let color = (try? ZoneColor(hex: hex)) ?? (try! ZoneColor(hex: "#000000"))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let start = formatter.date(from: startTime) ?? Date()
        let end = formatter.date(from: endTime) ?? Date()
        let calendar = Calendar.current
        let sLocal = (try? LocalTime(hour: calendar.component(.hour, from: start), minute: calendar.component(.minute, from: start))) ?? (try! LocalTime(hour: 0, minute: 0))
        let eLocal = (try? LocalTime(hour: calendar.component(.hour, from: end), minute: calendar.component(.minute, from: end))) ?? (try! LocalTime(hour: 0, minute: 0))
        
        let drafts = suggestedZones.map(\.asDraft)
        let newZone = Zone(
            id: id,
            name: name,
            color: color,
            startTime: sLocal,
            endTime: eLocal,
            category: suggestedZones.first(where: { $0.id == id })?.category
        )
        let updated = manageDailyZoneScheduleUseCase.updatingZone(newZone, in: drafts)
        suggestedZones = updated.map(\.asSuggestedZone)
    }

    public func moveZone(from source: IndexSet, to destination: Int) {
        let updated = manageDailyZoneScheduleUseCase.movingZones(
            from: source,
            to: destination,
            in: suggestedZones.map(\.asDraft)
        )
        suggestedZones = updated.map(\.asSuggestedZone)
    }

    public func swapZones(at sourceIndex: Int, with destinationIndex: Int) {
        let updated = manageDailyZoneScheduleUseCase.swapZones(
            suggestedZones.map(\.asDraft),
            at: sourceIndex,
            with: destinationIndex
        )
        suggestedZones = updated.map(\.asSuggestedZone)
    }

    public func firstAvailableTimeInterval() -> (start: Date, end: Date) {
        manageDailyZoneScheduleUseCase.firstAvailableInterval(
            wakeupTime: wakeupTime,
            existingZones: suggestedZones.map(\.asDraft)
        )
    }

    public func isTimeIntervalOverlapping(start: String, end: String, excludingID: UUID?) -> Bool {
        let drafts = suggestedZones.map(\.asDraft)
        return manageDailyZoneScheduleUseCase.isOverlapping(start: start, end: end, in: drafts, excludingID: excludingID)
    }

    public func isTimeIntervalOutsideActiveHours(start: Date, end: Date) -> Bool {
        manageDailyZoneScheduleUseCase.isOutsideActiveHours(
            start: start,
            end: end,
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    public func saveCurrentTemplate() async {
        guard let currentTemplate else { return }

        do {
            _ = try await updateTemplateUseCase.execute(
                id: currentTemplate.id,
                zones: suggestedZones.map(\.asDraft)
            )
            await load()
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    public var errorMessage: String? {
        guard case let .failure(message) = state else { return nil }
        return message
    }

    public func dismissError() {
        state = currentTemplate == nil ? .idle : .content
    }

    private func refreshZones() {
        guard let currentTemplate else {
            suggestedZones = []
            return
        }

        suggestedZones = manageDailyZoneScheduleUseCase
            .zones(forTemplate: currentTemplate)
            .map(\.asSuggestedZone)
    }
    
    private func dayValue(_ day: String) -> Int {
        switch day.uppercased() {
        case "MONDAY": return 0
        case "TUESDAY": return 1
        case "WEDNESDAY": return 2
        case "THURSDAY": return 3
        case "FRIDAY": return 4
        case "SATURDAY": return 5
        case "SUNDAY": return 6
        default: return 7
        }
    }
}

public enum DailyZonesState: Equatable, Sendable {
    case idle
    case loading
    case content
    case failure(String)
}

extension LocalTime {
    func toDate() -> Date? {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
}
