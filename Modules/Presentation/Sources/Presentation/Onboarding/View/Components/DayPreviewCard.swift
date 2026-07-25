//
//  DayPreviewCard.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct DayPreviewCard: View {
    let wakeupTime: Date
    let sleepTime: Date

    private var wakeLabel: String {
        wakeupTime.formatted(date: .omitted, time: .shortened)
    }

    private var sleepLabel: String {
        sleepTime.formatted(date: .omitted, time: .shortened)
    }

    private var availableHours: Int {
        let calendar = Calendar.current
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeupTime)
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)

        let wakeMinutes = (wakeComponents.hour ?? 7) * 60 + (wakeComponents.minute ?? 0)
        var sleepMinutes = (sleepComponents.hour ?? 23) * 60 + (sleepComponents.minute ?? 0)

        if sleepMinutes <= wakeMinutes {
            sleepMinutes += 24 * 60
        }

        return (sleepMinutes - wakeMinutes) / 60
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(L10n.Onboarding.yourDayLabel)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .kerning(1)
                Spacer()
                Text(L10n.Onboarding.openSkyHours(availableHours))
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 1.0, green: 0.95, blue: 0.7), location: 0.0),
                        .init(color: AppColors.skyGradientTop, location: 0.25),
                        .init(color: AppColors.skyGradientBottom, location: 0.7),
                        .init(color: Color(red: 0.3, green: 0.35, blue: 0.5), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    HStack {
                        Text(wakeLabel)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.destructive)
                        Spacer()
                        Text("☀️")
                            .font(.title2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Spacer()

                    Text(L10n.Onboarding.zonesFillNext)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.brandDarkBlue.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            AppColors.surface.opacity(0.8),
                            in: Capsule()
                        )

                    Spacer()

                    HStack {
                        Text(sleepLabel)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.onAccent)
                        Spacer()
                        Text("🌙")
                            .font(.title2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.outline.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: AppColors.shadow.opacity(0.06), radius: 12, y: 6)
    }
}

#Preview {
    DayPreviewCard(wakeupTime: Date.mockWakeTime, sleepTime: Date.mockSleepTime)
        .padding()
        .background(AppColors.skyGradientBottom)
}


#Preview {
    DayPreviewCard(wakeupTime: Date(), sleepTime: Date().addingTimeInterval(3600 * 16))
        .padding()
}

