import AppIntents
import Combine
import Domain
import Foundation

public struct TaskCategoryAppEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    public static var defaultQuery = TaskCategoryEntityQuery()

    public let id: UUID
    public let name: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(category: TaskCategory) {
        id = category.id
        name = category.name
    }
}

public struct TaskCategoryEntityQuery: EntityQuery {
    @AppDependency
    private var dependencies: AddTaskIntentDependencies

    public init() {}

    public func entities(for identifiers: [UUID]) async throws -> [TaskCategoryAppEntity] {
        let identifierSet = Set(identifiers)
        return try await categories().filter { identifierSet.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [TaskCategoryAppEntity] {
        try await categories()
    }

    private func categories() async throws -> [TaskCategoryAppEntity] {
        var latestCategories: [TaskCategory]?

        do {
            for try await categories in dependencies.fetchCategories.observe().values {
                latestCategories = categories
            }
        } catch {
            guard latestCategories == nil else {
                return latestCategories?.map(TaskCategoryAppEntity.init(category:)) ?? []
            }
            throw error
        }

        return latestCategories?.map(TaskCategoryAppEntity.init(category:)) ?? []
    }
}
