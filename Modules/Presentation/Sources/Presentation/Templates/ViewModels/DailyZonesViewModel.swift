import Foundation
import Observation
import Domain
import SwiftUI
import Common

@Observable
@MainActor
public final class DailyZonesViewModel: ZoneManaging {
    public var state: DailyZonesState = .idle
    public var isAddZoneSheetPresented: Bool = false
    public var editingZone: SuggestedZone?

    // Extracted from templates
    public var suggestedZones: [SuggestedZone] = []
    
    // User preferences
    public var wakeupTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? .now
    public var sleepTime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? .now
    
    // Day Selection
    public var availableDays: [String] = []
    public var selectedDay: String?

    // Domain dependencies
    private let fetchTemplatesUseCase: any FetchTemplatesUseCase
    private let updateTemplateUseCase: any UpdateTemplateUseCase
    private let getUserProfileUseCase: any GetUserProfileUseCase
    private let manageZoneScheduleUseCase: any ManageZoneScheduleUseCase
    
    // Current template
    private var templates: [Template] = []
    private var currentTemplate: Template? {
        guard let day = selectedDay else { return nil }
        return templates.first { $0.daysOfWeek.contains(day) }
    }

    public init(
        fetchTemplatesUseCase: any FetchTemplatesUseCase,
        updateTemplateUseCase: any UpdateTemplateUseCase,
        getUserProfileUseCase: any GetUserProfileUseCase,
        manageZoneScheduleUseCase: any ManageZoneScheduleUseCase
    ) {
        self.fetchTemplatesUseCase = fetchTemplatesUseCase
        self.updateTemplateUseCase = updateTemplateUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.manageZoneScheduleUseCase = manageZoneScheduleUseCase
    }

    public func load() async {
        state = .loading
        do {
            async let profileTask = getUserProfileUseCase.execute()
            async let templatesTask = fetchTemplatesUseCase.execute()
            
            let (profile, fetchedTemplates) = try await (profileTask, templatesTask)
            
            self.templates = fetchedTemplates
            
            if let wake = profile.preferences.wakeupTime.toDate() {
                self.wakeupTime = wake
            }
            if let sleep = profile.preferences.sleepTime.toDate() {
                self.sleepTime = sleep
            }

            self.availableDays = Array(Set(fetchedTemplates.flatMap(\.daysOfWeek))).sorted(by: {
                dayValue($0) < dayValue($1)
            })
            
            if let firstDay = self.availableDays.first, selectedDay == nil {
                self.selectedDay = firstDay
            }
            
            self.refreshZones()
            state = .content
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func selectDay(_ day: String) {
        self.selectedDay = day
        refreshZones()
    }

    private func refreshZones() {
        guard let template = currentTemplate else {
            suggestedZones = []
            return
        }
        
        let drafts = template.zones.map(\.asSuggestedZone).map(\.asDraft)
        let sorted = manageZoneScheduleUseCase.sortedChronologically(drafts)
        suggestedZones = sorted.map(\.asSuggestedZone)
    }

    public var availableHours: Int {
        let calendar = Calendar.current
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeupTime)
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)

        let wakeMinutes = (wakeComponents.hour ?? 7) * 60 + (wakeComponents.minute ?? 0)
        var sleepMinutes = (sleepComponents.hour ?? 23) * 60 + (sleepComponents.minute ?? 0)

        if sleepMinutes <= wakeMinutes {
            sleepMinutes += 24 * 60
        }

        return (sleepMinutes - wakeMinutes) / 60
    }
    
    public var hasZoneOutsideActiveHours: Bool {
        suggestedZones.contains { zone in
            guard let start = manageZoneScheduleUseCase.parseTime(zone.startTime),
                  let end = manageZoneScheduleUseCase.parseTime(zone.endTime) else { return false }
            return isTimeIntervalOutsideActiveHours(start: start, end: end)
        }
    }

    // MARK: - Zone Actions
    
    public func removeZone(_ zone: SuggestedZone) {
        suggestedZones.removeAll { $0.id == zone.id }
        // Save changes here or wait for explicit save? The prompt says "save Tuesday" at the bottom of the screen.
    }
    
    public func addZone(_ zone: SuggestedZone) {
        suggestedZones.append(zone)
        sortZonesChronologically()
    }
    
    public func updateZone(
        id: UUID, name: String, colorRed: Double, colorGreen: Double, colorBlue: Double, startTime: String, endTime: String
    ) {
        guard let index = suggestedZones.firstIndex(where: { $0.id == id }) else { return }
        suggestedZones[index].name = name
        suggestedZones[index].colorRed = colorRed
        suggestedZones[index].colorGreen = colorGreen
        suggestedZones[index].colorBlue = colorBlue
        suggestedZones[index].startTime = startTime
        suggestedZones[index].endTime = endTime
        sortZonesChronologically()
    }
    
    public func moveZone(from source: IndexSet, to destination: Int) {
        let timeSlots = suggestedZones.map { (start: $0.startTime, end: $0.endTime) }
        suggestedZones.move(fromOffsets: source, toOffset: destination)
        for index in suggestedZones.indices {
            suggestedZones[index].startTime = timeSlots[index].start
            suggestedZones[index].endTime = timeSlots[index].end
        }
    }

    public func swapZones(at sourceIndex: Int, with destinationIndex: Int) {
        let drafts = suggestedZones.map(\.asDraft)
        let updated = manageZoneScheduleUseCase.swapZones(drafts, at: sourceIndex, with: destinationIndex)
        suggestedZones = updated.map(\.asSuggestedZone)
    }

    private func sortZonesChronologically() {
        let drafts = suggestedZones.map(\.asDraft)
        let sorted = manageZoneScheduleUseCase.sortedChronologically(drafts)
        suggestedZones = sorted.map(\.asSuggestedZone)
    }

    // MARK: - ZoneManaging Requirements

    public func firstAvailableTimeInterval() -> (start: Date, end: Date) {
        let drafts = suggestedZones.map(\.asDraft)
        return manageZoneScheduleUseCase.firstAvailableInterval(wakeupTime: wakeupTime, existingZones: drafts)
    }

    public func isTimeIntervalOverlapping(start: String, end: String, excludingID: UUID?) -> Bool {
        let drafts = suggestedZones.map(\.asDraft)
        return manageZoneScheduleUseCase.isOverlapping(start: start, end: end, in: drafts, excludingID: excludingID)
    }

    public func isTimeIntervalOutsideActiveHours(start: Date, end: Date) -> Bool {
        manageZoneScheduleUseCase.isOutsideActiveHours(
            start: start,
            end: end,
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }
    
    // MARK: - API Updates
    
    public func saveCurrentTemplate() async {
        guard let currentTemplate = currentTemplate else { return }
        let zones = suggestedZones.map(\.asDraft)
        do {
            _ = try await updateTemplateUseCase.execute(id: currentTemplate.id, zones: zones)
            // Reload after update
            await load()
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    // MARK: - Helpers

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
        components.hour = self.hour
        components.minute = self.minute
        return Calendar.current.date(from: components)
    }
}
