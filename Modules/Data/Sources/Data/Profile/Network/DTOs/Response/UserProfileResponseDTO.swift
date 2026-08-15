//
//  UserProfileResponseDTO.swift
//  Data
//

import Foundation

public struct UserPreferencesDTO: Decodable, Sendable {
    public let timezone: String
    public let preferredSessionDuration: Int
    public let bufferBetweenSessions: Int
    public let wakeupTime: String
    public let sleepTime: String
    public let schedulingType: String

    public init(
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupTime: String,
        sleepTime: String,
        schedulingType: String
    ) {
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
        self.schedulingType = schedulingType
    }
}

public struct StoreItemDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let image: String
    public let info: String?
    public let price: Int
    public let version: String
    public let type: String
}

public struct EquippedItemDTO: Decodable, Sendable {
    public let type: String
    public let item: StoreItemDTO
    public let equippedAt: String
}

public struct UserProfileResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let email: String
    public let firstName: String?
    public let lastName: String?
    public let birthDate: String?
    public let points: Int
    public let streak: Int
    public let maxStreak: Int
    public let profilePictureUrl: String?
    public let isNew: Bool?
    public let preferences: UserPreferencesDTO
    public let equippedItems: [EquippedItemDTO]?

    public init(
        id: UUID,
        email: String,
        firstName: String?,
        lastName: String?,
        birthDate: String?,
        points: Int,
        streak: Int,
        maxStreak: Int,
        profilePictureUrl: String?,
        isNew: Bool?,
        preferences: UserPreferencesDTO,
        equippedItems: [EquippedItemDTO]?
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.points = points
        self.streak = streak
        self.maxStreak = maxStreak
        self.profilePictureUrl = profilePictureUrl
        self.isNew = isNew
        self.preferences = preferences
        self.equippedItems = equippedItems
    }
}
