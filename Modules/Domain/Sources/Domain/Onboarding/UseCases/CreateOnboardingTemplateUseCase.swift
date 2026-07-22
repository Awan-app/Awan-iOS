//
//  CreateOnboardingTemplateUseCase.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//
import Foundation

public protocol CreateOnboardingTemplateUseCase: Sendable {
    func execute(zoneDrafts: [ZoneDraft]) async throws
}

public final class CreateOnboardingTemplateUseCaseImpl: CreateOnboardingTemplateUseCase {
    private let templateRepository: any TemplateRepository

    public init(templateRepository: any TemplateRepository) {
        self.templateRepository = templateRepository
    }

    public func execute(zoneDrafts: [ZoneDraft]) async throws {
        let zones = try mapZones(zoneDrafts)
        try await templateRepository.createWeeklyTemplate(zones: zones)
    }

    private func mapZones(_ drafts: [ZoneDraft]) throws -> [Zone] {
        try drafts.compactMap { draft -> Zone? in
            let hex = hexString(red: draft.colorRed, green: draft.colorGreen, blue: draft.colorBlue)

            guard let start = parseTime(draft.startTime),
                  let end = parseTime(draft.endTime) else { return nil }

            let calendar = Calendar.current
            return try Zone(
                id: draft.id,
                name: draft.name,
                color: ZoneColor(hex: hex),
                startTime: LocalTime(
                    hour: calendar.component(.hour, from: start),
                    minute: calendar.component(.minute, from: start)
                ),
                endTime: LocalTime(
                    hour: calendar.component(.hour, from: end),
                    minute: calendar.component(.minute, from: end)
                )
            )
        }
    }

    private func hexString(red: Double, green: Double, blue: Double) -> String {
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timeString)
    }
}
