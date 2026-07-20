//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import SwiftUI
import Common


// remove this model and use the right one for zone
struct Zone: Identifiable {
    let id = UUID()
    let name: String
    let timeRange: String
    let dotColor: Color
    let backgroundTint: Color
}

struct ZoneRow: View {
    let zone: Zone
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(zone.dotColor)
                    .frame(width: 8, height: 8)
                
                Text(zone.name)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(zone.dotColor)
            }
            
            Spacer()
            
            Text(zone.timeRange)
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(zone.backgroundTint)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 10) {
        ZoneRow(zone: Zone(name: "Study", timeRange: "7:00 – 9:30 AM", dotColor: AppColors.accentPurple, backgroundTint: AppColors.accentPurple.opacity(0.12)))
        ZoneRow(zone: Zone(name: "Work", timeRange: "9:30 AM – 1:00 PM", dotColor: AppColors.accentBlue, backgroundTint: AppColors.accentBlue.opacity(0.10)))
    }
    .padding()
    .background(AppColors.screenBackground)
}
