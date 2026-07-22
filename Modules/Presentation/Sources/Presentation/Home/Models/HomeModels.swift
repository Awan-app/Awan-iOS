import Domain
import Foundation
import SwiftUI

enum HomeStatus: Equatable {
    case idle
    case loading
    case ready
    case failure
}

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
    var status: HomeStatus
    var selectedDay: Date
    var displayName: String?
    var streakCount: Int
    var rewardPoints: Int
    var taskCount: Int
    var scheduledMinutes: Int
    var completedSessionCount: Int
    var totalSessionCount: Int
    var taskAllocations: [HomeTaskAllocationItem]
    var timelineWindow: HomeTimelineWindow?
    var timelineZones: [HomeTimelineZoneItem]
    var timelineItems: [HomeTimelineItem]
    var selectedSessionID: UUID?
    var isMutating: Bool
    var errorMessage: String?

    var isLoading: Bool { status == .loading }
    var selectedSession: HomeTimelineItem? {
        timelineItems.first { $0.id == selectedSessionID }
    }

    static func initial(selectedDay: Date) -> HomeState {
        HomeState(
            status: .idle,
            selectedDay: selectedDay,
            displayName: nil,
            streakCount: 0,
            rewardPoints: 0,
            taskCount: 0,
            scheduledMinutes: 0,
            completedSessionCount: 0,
            totalSessionCount: 0,
            taskAllocations: [],
            timelineWindow: nil,
            timelineZones: [],
            timelineItems: [],
            selectedSessionID: nil,
            isMutating: false,
            errorMessage: nil
        )
    }
}

struct HomeContent {
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
