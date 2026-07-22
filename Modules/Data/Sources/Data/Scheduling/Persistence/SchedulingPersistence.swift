import SwiftData

public enum SchedulingPersistence {
    public static var schema: Schema {
        Schema([
            GoalModel.self,
            TaskModel.self,
            SessionModel.self,
            ZoneModel.self,
            TemplateModel.self,
            TemplateOverrideModel.self,
            UserProfileModel.self,
        ])
    }
}
