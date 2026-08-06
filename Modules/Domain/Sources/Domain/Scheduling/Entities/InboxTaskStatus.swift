//
//  InboxTaskStatus.swift
//  Domain
//

import Foundation

public enum InboxTaskStatus: Hashable, Sendable {
    case drafted
    case active
    case completed
}
