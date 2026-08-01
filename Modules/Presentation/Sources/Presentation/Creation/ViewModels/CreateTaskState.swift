import Domain
import Foundation

enum CreateTaskPhase: Equatable {
    case composer
    case aiLoading
    case aiResult(AITaskSheetItem)
    case imageUploading(String)
    case imageTasksResult(TaskProposalResponse)
}

struct CreateTaskState {
    var zones: [Zone] = []
    var isLoadingZones = false
    var isSubmitting = false
    var errorMessage: String?
    var didCreateTask = false
    var phase: CreateTaskPhase = .composer
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
}
