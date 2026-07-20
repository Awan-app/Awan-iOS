//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import Domain
import SwiftUI

struct ZoneRow: View {
    let zone: Zone

    private var dotColor: Color {
        AppColors.runtime(hex: zone.color.hex)
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)

                Text(zone.name)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(dotColor)
            }

            Spacer()

            Text(timeRangeString)
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(dotColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var timeRangeString: String {
        let startIsPM = zone.startTime.hour >= 12
        let endIsPM = zone.endTime.hour >= 12
        
        let startStr = formatTime(zone.startTime, includeAMPM: startIsPM != endIsPM)
        let endStr = formatTime(zone.endTime, includeAMPM: true)
        
        return "\(startStr) – \(endStr)"
    }
    
    private func formatTime(_ time: LocalTime, includeAMPM: Bool) -> String {
        let isPM = time.hour >= 12
        let displayHour = time.hour % 12 == 0 ? 12 : time.hour % 12
        let displayMinute = String(format: "%02d", time.minute)
        
        if includeAMPM {
            return "\(displayHour):\(displayMinute) \(isPM ? "PM" : "AM")"
        } else {
            return "\(displayHour):\(displayMinute)"
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        ZoneRow(
            zone: Zone(
                id: UUID(),
                name: "Study",
                color: try! ZoneColor(hex: "#800080"),
                startTime: try! LocalTime(hour: 7, minute: 0),
                endTime: try! LocalTime(hour: 9, minute: 30)
            )
        )
        ZoneRow(
            zone: Zone(
                id: UUID(),
                name: "Work",
                color: try! ZoneColor(hex: "#0000FF"),
                startTime: try! LocalTime(hour: 9, minute: 30),
                endTime: try! LocalTime(hour: 13, minute: 0)
            )
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}
