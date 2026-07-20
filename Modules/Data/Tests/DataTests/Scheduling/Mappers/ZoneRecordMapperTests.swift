import XCTest
import Domain
@testable import Data

final class ZoneRecordMapperTests: XCTestCase {
    func testToDomainWithNilTemplates() throws {
        let id = UUID()
        let record = ZoneRecord(id: id, name: "Zone", colorHex: "#FFFFFF", startHour: 1, startMinute: 0, endHour: 2, endMinute: 0, templateID: nil, templateOverrideID: nil)
        
        let domain = try record.toDomain()
        
        XCTAssertEqual(domain.templateID, nil)
        XCTAssertEqual(domain.templateOverrideID, nil)
    }

    func testToDomainWithTemplateOnly() throws {
        let id = UUID()
        let tId = UUID()
        let record = ZoneRecord(id: id, name: "Zone", colorHex: "#FFFFFF", startHour: 1, startMinute: 0, endHour: 2, endMinute: 0, templateID: tId, templateOverrideID: nil)
        
        let domain = try record.toDomain()
        
        XCTAssertEqual(domain.templateID, tId)
        XCTAssertEqual(domain.templateOverrideID, nil)
    }

    func testToDomainWithOverrideOnly() throws {
        let id = UUID()
        let toId = UUID()
        let record = ZoneRecord(id: id, name: "Zone", colorHex: "#FFFFFF", startHour: 1, startMinute: 0, endHour: 2, endMinute: 0, templateID: nil, templateOverrideID: toId)
        
        let domain = try record.toDomain()
        
        XCTAssertEqual(domain.templateID, nil)
        XCTAssertEqual(domain.templateOverrideID, toId)
    }

    func testInitFromDomainWithTemplateOnly() throws {
        let id = UUID()
        let tId = UUID()
        let domain = Zone(id: id, name: "Zone", color: ZoneColor(hex: "#FFFFFF"), startTime: LocalTime(hour: 1, minute: 0), endTime: LocalTime(hour: 2, minute: 0), templateID: tId, templateOverrideID: nil)
        
        let record = ZoneRecord(domain: domain)
        
        XCTAssertEqual(record.templateID, tId)
        XCTAssertEqual(record.templateOverrideID, nil)
    }
}
