//
//  DailyZoneBarsView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common
import Domain

/// Coloured capsule bars with a dot-and-line timeline below them.
/// The widths of the bars are proportional to the zone's duration.
struct DailyZoneBarsView: View {
    let zones: [Zone]
    
    private var totalDuration: Double {
        let total = zones.reduce(0.0) { sum, zone in
            sum + duration(for: zone)
        }
        return total > 0 ? total : 1.0 // Prevent division by zero
    }
    
    private func duration(for zone: Zone) -> Double {
        let dur = zone.endTime.minutesSinceMidnight - zone.startTime.minutesSinceMidnight
        return dur > 0 ? Double(dur) : Double(1440 + dur)
    }

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 5
            let dotWidth: CGFloat = 6
            let totalSpacing = spacing * CGFloat(max(0, zones.count - 1))
            let availableWidth = max(0, geo.size.width - totalSpacing)
            
            VStack(spacing: 5) {
                // MARK: - Zone Bars
                HStack(spacing: spacing) {
                    ForEach(zones) { zone in
                        let fraction = duration(for: zone) / totalDuration
                        let width = availableWidth * CGFloat(fraction)
                        
                        Capsule()
                            .fill(Color(zoneColor: zone.color))
                            .frame(width: width, height: 7)
                    }
                }
                
                // MARK: - Dot Timeline
                ZStack(alignment: .leading) {
                    // Continuous line
                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.20))
                        .frame(height: 1.5)
                        .padding(.horizontal, dotWidth / 2)
                    
                    // Dots
                    ForEach(0...zones.count, id: \.self) { index in
                        Circle()
                            .fill(AppColors.textSecondary.opacity(0.35))
                            .frame(width: dotWidth, height: dotWidth)
                            .offset(x: offsetForDot(at: index, availableWidth: availableWidth, spacing: spacing))
                    }
                }
            }
        }
        .frame(height: 18) // 7 (capsule) + 5 (spacing) + 6 (dot)
    }
    
    private func offsetForDot(at index: Int, availableWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        if index == 0 { return 0 }
        let totalWidth = availableWidth + CGFloat(zones.count - 1) * spacing
        if index == zones.count { return totalWidth - 6 }
        
        let durationSum = zones.prefix(index).reduce(0.0) { $0 + duration(for: $1) }
        let fraction = durationSum / totalDuration
        let widthSum = availableWidth * CGFloat(fraction)
        let spacesSum = CGFloat(index) * spacing
        
        return widthSum + spacesSum - (spacing / 2) - 3
    }
}
