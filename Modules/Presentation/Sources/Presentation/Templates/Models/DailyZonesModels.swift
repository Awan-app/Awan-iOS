import Domain
import Foundation

enum DailyZonesMode: String, CaseIterable, Sendable {
    case weekly
    case override
}

enum WeekNavigationDirection: Equatable, Sendable {
    case backward
    case forward
}

enum DailyZonesLoadPhase: Equatable, Sendable {
    case idle
    case loading
    case content
    case failure(String)
}

struct DailyZoneDraft: Identifiable, Equatable, Sendable {
    let id: UUID
    let serverID: UUID?
    var name: String
    var color: ZoneColor
    var startTime: LocalTime
    var endTime: LocalTime
    var category: TaskCategory?

    init(zone: Zone) {
        id = zone.id
        serverID = zone.id
        name = zone.name
        color = zone.color
        startTime = zone.startTime
        endTime = zone.endTime
        category = zone.category
    }

    init(
        id: UUID = UUID(),
        serverID: UUID? = nil,
        name: String,
        color: ZoneColor,
        startTime: LocalTime,
        endTime: LocalTime,
        category: TaskCategory? = nil
    ) {
        self.id = id
        self.serverID = serverID
        self.name = name
        self.color = color
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
    }

    var mutation: TemplateZoneMutation {
        TemplateZoneMutation(
            id: serverID,
            name: name,
            color: color,
            startTime: startTime,
            endTime: endTime,
            category: category
        )
    }

    var creationZone: Zone {
        Zone(
            id: id,
            name: name,
            color: color,
            startTime: startTime,
            endTime: endTime,
            category: category
        )
    }
}

enum TemplateCreationKind: String, CaseIterable, Sendable {
    case weekly
    case override
}

struct TemplateCreationForm: Equatable, Sendable {
    var kind: TemplateCreationKind = .weekly
    var name = ""
    var weekdays: Set<TemplateWeekday> = []
    var date: Date
    var conflictMessage: String?
    var isSubmitting = false
}

struct TemplateDetailsForm: Equatable, Sendable {
    let id: UUID
    var name: String
    var weekdays: Set<TemplateWeekday>
    var conflictMessage: String?
    var isSubmitting = false
}

struct ZoneEditorForm: Equatable, Sendable {
    let editingID: UUID?
    var name: String
    var selectedColorIndex: Int
    var startTime: Date
    var endTime: Date
    var selectedCategoryID: UUID?
    var overlapMessage: String?
    var outsideHoursWarning = false
}

struct DailyZoneDragState: Equatable, Sendable {
    let zoneID: UUID
    var offset: Double
    var cumulativeTranslation: Double
}

enum DailyZonesSheet: Hashable, Identifiable, Sendable {
    case createTemplate
    case editTemplate
    case editOverride
    case zoneEditor

    var id: Self { self }
}

enum DailyZonesDestination: Equatable, Sendable {
    case mode(DailyZonesMode)
    case template(UUID)
    case date(TemplateOverrideDate)
    case dismiss
}

enum DailyZonesDialog: Equatable, Sendable {
    case deleteZone(DailyZoneDraft)
    case applyZoneEdit(original: DailyZoneDraft, updated: DailyZoneDraft)
    case unsavedChanges(DailyZonesDestination)
    case deleteTemplate(Template)
    case deleteOverride(TemplateOverride)
}

struct DailyZonesState: Equatable, Sendable {
    var phase: DailyZonesLoadPhase = .idle
    var mode: DailyZonesMode = .weekly
    var templates: [Template] = []
    var overrides: [TemplateOverride] = []
    var categories: [TaskCategory] = []
    var categoryErrorMessage: String?
    var selectedTemplateID: UUID?
    var selectedDate: TemplateOverrideDate?
    var weekNavigationDirection: WeekNavigationDirection = .forward
    var zones: [DailyZoneDraft] = []
    var baselineZones: [DailyZoneDraft] = []
    var wakeupTime: LocalTime?
    var sleepTime: LocalTime?
    var timeZoneIdentifier = TimeZone.current.identifier
    var weekdayAvailability: [TemplateWeekdayAvailability] = []
    var sheet: DailyZonesSheet?
    var creationForm: TemplateCreationForm?
    var templateForm: TemplateDetailsForm?
    var zoneForm: ZoneEditorForm?
    var zoneDrag: DailyZoneDragState?
    var dialog: DailyZonesDialog?
    var errorMessage: String?
    var isSaving = false
    var isCreatingCategory = false
    var shouldDismiss = false

    var isDirty: Bool { zones != baselineZones }
    var areZonesCategorized: Bool {
        !categories.isEmpty && zones.allSatisfy { zone in
            guard let categoryID = zone.category?.id else { return false }
            return categories.contains { $0.id == categoryID }
        }
    }
}

enum DailyZonesAction {
    case appeared
    case retry
    case selectMode(DailyZonesMode)
    case selectTemplate(UUID)
    case selectDate(Date)
    case previousWeek
    case nextWeek
    case requestDismiss
    case dismissCompleted
    case presentCreation
    case dismissSheet
    case setCreationKind(TemplateCreationKind)
    case setCreationName(String)
    case toggleCreationWeekday(TemplateWeekday)
    case setCreationDate(Date)
    case submitCreation
    case presentTemplateEditor
    case setTemplateName(String)
    case toggleTemplateWeekday(TemplateWeekday)
    case submitTemplateDetails
    case presentOverrideEditor
    case submitOverrideDetails
    case requestDeleteTemplate
    case requestDeleteOverride
    case presentAddZone
    case presentEditZone(UUID)
    case setZoneName(String)
    case setZoneColor(Int)
    case setZoneStart(Date)
    case setZoneEnd(Date)
    case setZoneCategory(UUID?)
    case retryCategories
    case createCategory(String)
    case submitZoneForm
    case requestDeleteZone(UUID)
    case dragZone(id: UUID, translation: Double, rowStride: Double)
    case endZoneDrag
    case confirmDialog
    case discardAndContinue
    case cancelDialog
    case save
    case dismissError
}
