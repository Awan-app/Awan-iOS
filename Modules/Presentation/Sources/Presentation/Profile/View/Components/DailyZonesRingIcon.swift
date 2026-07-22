//
//  DailyZonesRingIcon.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common
import Domain

/// Coloured arc-segment ring with a clock icon in the centre.
/// Each element in `zones` becomes one arc segment, proportionally sized by duration.
struct DailyZonesRingIcon: View {
    let zones: [Zone]

    private let lineWidth: CGFloat = 7
    private let gapFraction: Double = 0.035
    
    private var totalDuration: Double {
        let total = zones.reduce(0.0) { sum, zone in
            sum + duration(for: zone)
        }
        return total > 0 ? total : 1.0
    }
    
    private func duration(for zone: Zone) -> Double {
        let dur = zone.endTime.minutesSinceMidnight - zone.startTime.minutesSinceMidnight
        return dur > 0 ? Double(dur) : Double(1440 + dur)
    }

    var body: some View {
        ZStack {
            arcs
            clockIcon
        }
        .frame(width: 64, height: 64)
    }

    // MARK: - Arcs

    private var arcs: some View {
        let count = max(zones.count, 1)
        let totalGapFraction = Double(count) * gapFraction
        let availableFraction = max(0.0, 1.0 - totalGapFraction)
        
        // Precalculate start and end fractions for each segment to avoid mutating state in ForEach
        var segments: [(start: Double, end: Double, color: Color)] = []
        var currentStart: Double = 0.0
        
        for zone in zones {
            let fraction = duration(for: zone) / totalDuration
            let segmentLength = availableFraction * fraction
            
            segments.append((
                start: currentStart,
                end: currentStart + segmentLength,
                color: Color(zoneColor: zone.color)
            ))
            
            currentStart += segmentLength + gapFraction
        }
        
        return ZStack {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                Circle()
                    .trim(from: segment.start, to: segment.end)
                    .stroke(
                        segment.color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    // MARK: - Clock Icon

    private var clockIcon: some View {
        Image(systemName: "clock")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(AppColors.accentBlue)
    }
}
