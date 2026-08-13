import Domain
import Foundation
import SwiftUI

public struct SessionDetailsContext {
    public let session: Session
    public let task: AwanTask
    public let color: Color
    public let timeZoneIdentifier: String

    public init(
        session: Session,
        task: AwanTask,
        color: Color,
        timeZoneIdentifier: String
    ) {
        self.session = session
        self.task = task
        self.color = color
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

enum SessionDetailsConfirmation: Equatable {
    case delete
    case discardChanges
}

struct SessionDetailsState {
    let task: AwanTask
    let color: Color
    let timeZoneIdentifier: String
    let originalSession: Session

    var session: Session
    var selectedDay: Date
    var draftStart: Date
    var draftEnd: Date
    var durationMinutes: Int?
    var selectedDurationMinutes: Int?
    var statusUIModel: SessionDetailsStatusUIModel
    var lockLabel: String
    var validationMessage: String?
    var isDirty: Bool
    var isSaving = false
    var isLocking = false
    var isDeleting = false
    var confirmation: SessionDetailsConfirmation?
    var errorMessage: String?
    var shouldDismiss = false

    var isValid: Bool { validationMessage == nil }
    var isBusy: Bool { isSaving || isLocking || isDeleting }
    var canSave: Bool { isDirty && isValid && !isBusy }
}

enum SessionDetailsAction {
    case refreshStatus
    case setDay(Date)
    case setStartTime(Date)
    case setEndTime(Date)
    case adjustStart(minutes: Int)
    case adjustEnd(minutes: Int)
    case selectDuration(minutes: Int)
    case save
    case toggleLock
    case requestDelete
    case confirmDelete
    case attemptDismiss
    case discardAndDismiss
    case cancelConfirmation
    case dismissError
}

public struct SessionDetailsUseCases: Sendable {
    public let updateSchedule: any UpdateSessionScheduleUseCase
    public let setLock: any SetSessionLockUseCase
    public let delete: any DeleteSessionUseCase

    public init(
        updateSchedule: any UpdateSessionScheduleUseCase,
        setLock: any SetSessionLockUseCase,
        delete: any DeleteSessionUseCase
    ) {
        self.updateSchedule = updateSchedule
        self.setLock = setLock
        self.delete = delete
    }
}
