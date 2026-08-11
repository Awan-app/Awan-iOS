import Domain

public struct DailyZonesUseCases: Sendable {
    let fetchTemplates: any FetchTemplatesUseCase
    let fetchCategories: any FetchCategoriesUseCase
    let createCategory: any CreateCategoryUseCase
    let fetchOverrides: any FetchTemplateOverridesUseCase
    let createTemplate: any CreateTemplateUseCase
    let updateTemplateZones: any UpdateTemplateUseCase
    let updateTemplateDetails: any UpdateTemplateDetailsUseCase
    let deleteTemplate: any DeleteTemplateUseCase
    let createOverride: any CreateTemplateOverrideUseCase
    let updateOverrideZones: any UpdateBulkTemplateOverrideUseCase
    let updateOverrideDetails: any UpdateTemplateOverrideUseCase
    let deleteOverride: any DeleteTemplateOverrideUseCase
    let getUserProfile: any GetUserProfileUseCase
    let manageSchedule: any ManageDailyZoneScheduleUseCase
    let resolveWeekdays: any ResolveTemplateWeekdayAvailabilityUseCase

    public init(
        fetchTemplates: any FetchTemplatesUseCase,
        fetchCategories: any FetchCategoriesUseCase,
        createCategory: any CreateCategoryUseCase,
        fetchOverrides: any FetchTemplateOverridesUseCase,
        createTemplate: any CreateTemplateUseCase,
        updateTemplateZones: any UpdateTemplateUseCase,
        updateTemplateDetails: any UpdateTemplateDetailsUseCase,
        deleteTemplate: any DeleteTemplateUseCase,
        createOverride: any CreateTemplateOverrideUseCase,
        updateOverrideZones: any UpdateBulkTemplateOverrideUseCase,
        updateOverrideDetails: any UpdateTemplateOverrideUseCase,
        deleteOverride: any DeleteTemplateOverrideUseCase,
        getUserProfile: any GetUserProfileUseCase,
        manageSchedule: any ManageDailyZoneScheduleUseCase,
        resolveWeekdays: any ResolveTemplateWeekdayAvailabilityUseCase
    ) {
        self.fetchTemplates = fetchTemplates
        self.fetchCategories = fetchCategories
        self.createCategory = createCategory
        self.fetchOverrides = fetchOverrides
        self.createTemplate = createTemplate
        self.updateTemplateZones = updateTemplateZones
        self.updateTemplateDetails = updateTemplateDetails
        self.deleteTemplate = deleteTemplate
        self.createOverride = createOverride
        self.updateOverrideZones = updateOverrideZones
        self.updateOverrideDetails = updateOverrideDetails
        self.deleteOverride = deleteOverride
        self.getUserProfile = getUserProfile
        self.manageSchedule = manageSchedule
        self.resolveWeekdays = resolveWeekdays
    }
}
