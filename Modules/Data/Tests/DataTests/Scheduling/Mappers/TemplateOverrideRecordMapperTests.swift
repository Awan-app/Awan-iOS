import XCTest
import Domain
@testable import Data

final class TemplateOverrideRecordMapperTests: XCTestCase {
    func testToDomain() {
        let id = UUID()
        let userID = UUID()
        let date = Date()
        let record = TemplateOverrideRecord(id: id, name: "Test Override", createdAt: date, dateOfDay: date, userID: userID)
        
        let domain = record.toDomain()
        
        XCTAssertEqual(domain.id, id)
        XCTAssertEqual(domain.name, "Test Override")
        XCTAssertEqual(domain.createdAt, date)
        XCTAssertEqual(domain.dateOfDay, date)
        XCTAssertEqual(domain.userID, userID)
    }

    func testInitFromDomain() {
        let id = UUID()
        let userID = UUID()
        let date = Date()
        let domain = TemplateOverride(id: id, name: "Domain Override", createdAt: date, dateOfDay: date, userID: userID)
        
        let record = TemplateOverrideRecord(domain: domain)
        
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.name, "Domain Override")
        XCTAssertEqual(record.createdAt, date)
        XCTAssertEqual(record.dateOfDay, date)
        XCTAssertEqual(record.userID, userID)
    }
}
