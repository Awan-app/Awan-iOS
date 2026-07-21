//
//  DailyZoneBarsView.swift
//  Presentation
//

import SwiftUI
import Common

/// Coloured capsule bars with a dot-and-line timeline below them.
/// The number of bars and dots is driven by the `colors` array.
struct DailyZoneBarsView: View {
    let colors: [Color]

    var body: some View {
        VStack(spacing: 5) {
            zoneBars
            dotTimeline
        }
    }

    // MARK: - Zone Bars

    private var zoneBars: some View {
        HStack(spacing: 5) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                Capsule()
                    .fill(color)
                    .frame(height: 7)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Dot Timeline

    private var dotTimeline: some View {
        HStack(spacing: 0) {
            ForEach(0..<(colors.count + 1), id: \.self) { index in
                dot
                if index < colors.count {
                    line
                }
            }
        }
    }

    private var dot: some View {
        Circle()
            .fill(AppColors.textSecondary.opacity(0.35))
            .frame(width: 6, height: 6)
    }

    private var line: some View {
        Rectangle()
            .fill(AppColors.textSecondary.opacity(0.20))
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
    }
}
