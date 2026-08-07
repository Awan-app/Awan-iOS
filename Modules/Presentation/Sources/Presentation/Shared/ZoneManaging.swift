import Foundation
import Observation
import Domain

@MainActor
public protocol ZoneManaging: AnyObject {
    var isAddZoneSheetPresented: Bool { get set }
    var categories: [TaskCategory] { get }
    var categoryErrorMessage: String? { get }
    
    func firstAvailableTimeInterval() -> (start: Date, end: Date)
    func isTimeIntervalOverlapping(start: String, end: String, excludingID: UUID?) -> Bool
    func isTimeIntervalOutsideActiveHours(start: Date, end: Date) -> Bool
    func addZone(_ zone: SuggestedZone)
    func updateZone(id: UUID, name: String, colorRed: Double, colorGreen: Double, colorBlue: Double, startTime: String, endTime: String, category: TaskCategory)
    func retryCategories()
}
