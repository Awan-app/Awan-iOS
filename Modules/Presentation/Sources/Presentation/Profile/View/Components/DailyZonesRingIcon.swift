//
//  DailyZonesRingIcon.swift
//  Presentation
//

import SwiftUI
import Common

/// Coloured arc-segment ring with a clock icon in the centre.
/// Each element in `colors` becomes one arc segment, evenly spaced.
struct DailyZonesRingIcon: View {
    let colors: [Color]

    private let lineWidth: CGFloat = 7
    private let gapFraction: Double = 0.035

    var body: some View {
        ZStack {
            arcs
            clockIcon
        }
        .frame(width: 64, height: 64)
    }

    // MARK: - Arcs

    private var arcs: some View {
        let count = max(colors.count, 1)
        let segmentLength = (1.0 - Double(count) * gapFraction) / Double(count)

        return ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
            let start = Double(index) * (segmentLength + gapFraction)
            let end   = start + segmentLength

            Circle()
                .trim(from: start, to: end)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }

    // MARK: - Clock Icon

    private var clockIcon: some View {
        Image(systemName: "clock")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(AppColors.accentBlue)
    }
}
