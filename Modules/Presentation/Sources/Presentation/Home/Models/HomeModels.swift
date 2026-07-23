import Domain
import Foundation
import SwiftUI

struct HomeTimelineWindow: Equatable {
    let start: Date
    let end: Date

    var durationMinutes: Int {
        max(1, Int(end.timeIntervalSince(start) / 60))
    }
}

struct HomeTimelineItem: Identifiable, Hashable {
    let id: UUID
    let taskID: UUID
    let title: String
    let points: Int
    let color: Color
    let start: Date
    let end: Date
    let blocking: Bool
    let status: Session.Status
    let lane: Int
    let laneCount: Int

    var durationMinutes: Int {
        max(1, Int(end.timeIntervalSince(start) / 60))
    }
}

struct HomeTimelineZoneItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let color: Color
    let start: Date
    let end: Date
}

enum HomeTaskAllocationID: Hashable {
    case zone(UUID)
    case fallback
}

struct HomeTaskAllocationItem: Identifiable, Hashable {
    let id: HomeTaskAllocationID
    let color: Color
    let taskCount: Int
}

struct HomeState {
    var isLoading: Bool
    var success: HomeSuccessState?
    var failure: HomeFailureState?
    var selectedDay: Date
    var selectedSessionID: UUID?
    var isMutating: Bool
    var isAddTaskPresented: Bool
    var activeNudge: ScheduleNudge?

    var selectedSession: HomeTimelineItem? {
        success?.timelineItems.first { $0.id == selectedSessionID }
    }

    static func initial(selectedDay: Date) -> HomeState {
        HomeState(
            isLoading: false,
            success: nil,
            failure: nil,
            selectedDay: selectedDay,
            selectedSessionID: nil,
            isMutating: false,
            isAddTaskPresented: false,
            activeNudge: nil
        )
    }
}

struct HomeFailureState: Equatable {
    let message: String
}

struct HomeSuccessState {
    let tasks: [AwanTask]
    var sessions: [Session]
    let zones: [Zone]
    let profile: UserProfile
    let displayName: String?
    let streakCount: Int
    let rewardPoints: Int
    let taskCount: Int
    let scheduledMinutes: Int
    let completedSessionCount: Int
    let totalSessionCount: Int
    let taskAllocations: [HomeTaskAllocationItem]
    let timelineWindow: HomeTimelineWindow
    let timelineZones: [HomeTimelineZoneItem]
    let timelineItems: [HomeTimelineItem]
}
