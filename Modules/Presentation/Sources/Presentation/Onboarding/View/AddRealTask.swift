//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import Domain
import SwiftUI

struct AddRealTask: View {

    private let zones: [Zone] = [
        Zone(
            id: UUID(),
            name: "Study",
            color: try! ZoneColor(hex: "#800080"),
            startTime: try! LocalTime(hour: 7, minute: 0),
            endTime: try! LocalTime(hour: 9, minute: 30)
        ),
        Zone(
            id: UUID(),
            name: "Work",
            color: try! ZoneColor(hex: "#0000FF"),
            startTime: try! LocalTime(hour: 9, minute: 30),
            endTime: try! LocalTime(hour: 13, minute: 0)
        ),
        Zone(
            id: UUID(),
            name: "Personal",
            color: try! ZoneColor(hex: "#FFA500"),
            startTime: try! LocalTime(hour: 13, minute: 0),
            endTime: try! LocalTime(hour: 18, minute: 0)
        )
    ]

    var body: some View {
        ZStack {
            AppColors.skyGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        GreetingHeader(name: "Sam", zoneCount: zones.count)

                        VStack(spacing: 10) {
                            ForEach(zones) { zone in
                                ZoneRow(zone: zone)
                            }
                        }

                        EmptyStateCard {
                            // Add first task action
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }

            }
        }
    }
}

#Preview {
    AddRealTask()
}
