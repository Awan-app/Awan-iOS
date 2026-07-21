import Foundation

public enum SchedulingPersistenceError: Error, Equatable, Sendable {
    case duplicateID(UUID)
    case duplicateZoneID(UUID)
    case invalidWeekDays(Set<Int>)
    case overlappingTemplateWeekDays(Set<Int>)
    case duplicateOverrideDate(String)
    case invalidZoneOwnership(UUID)
}
