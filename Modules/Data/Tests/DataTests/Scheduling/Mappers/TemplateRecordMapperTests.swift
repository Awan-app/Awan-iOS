import XCTest
import Domain
@testable import Data

final class TemplateRecordMapperTests: XCTestCase {
    func testToDomain() {
        let id = UUID()
        let userID = UUID()
        let date = Date()
        let record = TemplateRecord(id: id, name: "Test Template", createdAt: date, dayOfWeek: 1, userID: userID)
        
        let domain = record.toDomain()
        
        XCTAssertEqual(domain.id, id)
        XCTAssertEqual(domain.name, "Test Template")
        XCTAssertEqual(domain.createdAt, date)
        XCTAssertEqual(domain.dayOfWeek, 1)
        XCTAssertEqual(domain.userID, userID)
    }

    func testInitFromDomain() {
        let id = UUID()
        let userID = UUID()
        let date = Date()
        let domain = Template(id: id, name: "Domain Template", createdAt: date, dayOfWeek: 2, userID: userID)
        
        let record = TemplateRecord(domain: domain)
        
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.name, "Domain Template")
        XCTAssertEqual(record.createdAt, date)
        XCTAssertEqual(record.dayOfWeek, 2)
        XCTAssertEqual(record.userID, userID)
    }
}
