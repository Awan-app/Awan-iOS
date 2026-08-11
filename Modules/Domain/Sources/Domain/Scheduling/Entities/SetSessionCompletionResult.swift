//
//  SetSessionCompletionResult.swift
//  Domain
//
//  Created by Eslam Elnady on 08/08/2026.
//


public enum SetSessionCompletionResult: Sendable {
    case completed(SessionCompletionResult)
    case uncompleted(Session)

    public var session: Session {
        switch self {
        case .completed(let result):
            result.session

        case .uncompleted(let session):
            session
        }
    }
}
