import Foundation
import Observation

@MainActor
public protocol ZoneManaging: AnyObject {
    var isAddZoneSheetPresented: Bool { get set }
    
    func firstAvailableTimeInterval() -> (start: Date, end: Date)
    func isTimeIntervalOverlapping(start: String, end: String, excludingID: UUID?) -> Bool
    func isTimeIntervalOutsideActiveHours(start: Date, end: Date) -> Bool
    func addZone(_ zone: SuggestedZone)
    func updateZone(id: UUID, name: String, colorRed: Double, colorGreen: Double, colorBlue: Double, startTime: String, endTime: String)
}
