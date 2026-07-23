//
//  SuggestedZone.swift
//  Presentation
//
//  Created by Me3bed on 20/07/2026.
//
import Foundation
import Domain

public struct SuggestedZone: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var startTime: String
    public var endTime: String
    public var colorRed: Double
    public var colorGreen: Double
    public var colorBlue: Double

    public init(id: UUID, name: String, startTime: String, endTime: String, colorRed: Double, colorGreen: Double, colorBlue: Double) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.colorRed = colorRed
        self.colorGreen = colorGreen
        self.colorBlue = colorBlue
    }
}

public extension SuggestedZone {
    var asDraft: Zone {
        let r = Int(round(colorRed * 255))
        let g = Int(round(colorGreen * 255))
        let b = Int(round(colorBlue * 255))
        let hex = String(format: "#%02X%02X%02X", r, g, b)
        
        let color = (try? ZoneColor(hex: hex)) ?? (try! ZoneColor(hex: "#000000"))
        
        let start = parseTime(startTime) ?? Date()
        let end = parseTime(endTime) ?? Date()
        let calendar = Calendar.current
        
        let startHour = calendar.component(.hour, from: start)
        let startMin = calendar.component(.minute, from: start)
        let endHour = calendar.component(.hour, from: end)
        let endMin = calendar.component(.minute, from: end)
        
        return Zone(
            id: id,
            name: name,
            color: color,
            startTime: (try? LocalTime(hour: startHour, minute: startMin)) ?? (try! LocalTime(hour: 0, minute: 0)),
            endTime: (try? LocalTime(hour: endHour, minute: endMin)) ?? (try! LocalTime(hour: 0, minute: 0))
        )
    }

    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timeString)
    }
}

public extension Zone {
    var asSuggestedZone: SuggestedZone {
        let hex = self.color.hex.replacingOccurrences(of: "#", with: "")
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        return SuggestedZone(
            id: id,
            name: name,
            startTime: formatTime(startTime),
            endTime: formatTime(endTime),
            colorRed: red,
            colorGreen: green,
            colorBlue: blue
        )
    }

    private func formatTime(_ time: LocalTime) -> String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = time.hour
        components.minute = time.minute
        if let date = calendar.date(from: components) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: date)
        }
        return "\(time.hour):\(String(format: "%02d", time.minute))"
    }
}
