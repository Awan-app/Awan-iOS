//
//  CreateOnboardingTemplateUseCase.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//
import Foundation

public protocol CreateOnboardingTemplateUseCase: Sendable {
    func execute(zoneDrafts: [Zone]) async throws
}

public final class CreateOnboardingTemplateUseCaseImpl: CreateOnboardingTemplateUseCase {
    private let templateRepository: any TemplateRepository

    public init(templateRepository: any TemplateRepository) {
        self.templateRepository = templateRepository
    }

    public func execute(zoneDrafts: [Zone]) async throws {
        try await templateRepository.createWeeklyTemplate(zones: zoneDrafts)
    }
}
