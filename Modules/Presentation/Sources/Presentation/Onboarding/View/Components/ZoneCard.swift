//
//  ZoneCard.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

extension SuggestedZone {
    var uiColor: Color {
        Color(red: colorRed, green: colorGreen, blue: colorBlue)
    }
}

struct ZoneCard: View {
    let zone: SuggestedZone
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.grid.3x3.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(zone.uiColor.opacity(0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text(zone.name)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(zone.uiColor)
                Text("\(zone.startTime) – \(zone.endTime)")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(zone.uiColor.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            zone.uiColor.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(zone.uiColor.opacity(0.15), lineWidth: 1)
        }
    }
}

struct AddZoneButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                Text("Add a zone")
                    .font(AppFonts.subheadlineHeavy)
            }
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        AppColors.divider,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
    }
}

//#Preview {
//    VStack(spacing: 12) {
//        ZoneCard(
//            zone: SuggestedZone(
//                id: UUID(),
//                name: "Study",
//                startTime: "7:00 AM",
//                endTime: "9:30 AM",
//                color: .teal
//            ),
//            onDelete: {}
//        )
//        AddZoneButton(onTap: {})
//    }
//    .padding()
//}
