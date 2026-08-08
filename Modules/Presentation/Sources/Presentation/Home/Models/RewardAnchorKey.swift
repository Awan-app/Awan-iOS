//
//  RewardAnchorKey.swift
//  Presentation
//
//  Created by Eslam Elnady on 08/08/2026.
//

import SwiftUI

struct RewardAnchorKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue: [String: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [String: Anchor<CGRect>],
        nextValue: () -> [String: Anchor<CGRect>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
