import Foundation
import SwiftData

public final class SwiftDataLocalDataWiper: LocalDataWiper, @unchecked Sendable {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    public func wipeAllData() async throws {
        let context = modelContainer.mainContext
        
        try deleteModels(ofType: TaskModel.self, in: context)
        try deleteModels(ofType: GoalModel.self, in: context)
        try deleteModels(ofType: SessionModel.self, in: context)
        try deleteModels(ofType: ZoneModel.self, in: context)
        try deleteModels(ofType: TemplateModel.self, in: context)
        try deleteModels(ofType: TemplateOverrideModel.self, in: context)
        try deleteModels(ofType: UserProfileModel.self, in: context)
        try deleteModels(ofType: CategoryModel.self, in: context)
        
        try context.save()
    }
    
    @MainActor
    private func deleteModels<T: PersistentModel>(ofType type: T.Type, in context: ModelContext) throws {
        let models = try context.fetch(FetchDescriptor<T>())
        for model in models {
            context.delete(model)
        }
    }
}
