import Domain
import Foundation

enum CreateTaskPhase: Equatable {
    case composer
    case aiLoading
    case aiResult([AITaskSheetItem])
}

struct CreateTaskState {
    var zones: [Zone] = []
    var isLoadingZones = false
    var isSubmitting = false
    var errorMessage: String?
    var didCreateTask = false
    var phase: CreateTaskPhase = .composer
    var pendingAITaskItems: [AITaskSheetItem] = []
    var quickText = ""
    var isAwanSchedulingEnabled = true
    var durationMinutes = 60
    var startsAt: Date
    var selectedCategoryID: UUID?
    var isRecording = false

    var categories: [TaskCategory] {
        var seen = Set<UUID>()
        return zones.compactMap { zone in
            guard let category = zone.category,
                  seen.insert(category.id).inserted
            else {
                return nil
            }
            return category
        }
    }

    mutating func startAILoading() {
        isSubmitting = true
        errorMessage = nil
        phase = .aiLoading
    }

    mutating func setAIResult(_ items: [AITaskSheetItem]) {
        pendingAITaskItems = items
        phase = .aiResult(items)
        isSubmitting = false
    }

    mutating func setAIError(_ message: String) {
        errorMessage = message
        phase = .composer
        isSubmitting = false
    }

    mutating func cancelAI() {
        phase = .composer
        isSubmitting = false
    }

    mutating func dismissAITaskResult() {
        pendingAITaskItems = []
        phase = .composer
    }
}

