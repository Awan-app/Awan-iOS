//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import SwiftUI
import Common

struct AddRealTask: View {
    
    private let zones: [Zone] = [
           Zone(name: "Study", timeRange: "7:00 – 9:30 AM", dotColor: AppColors.accentPurple, backgroundTint: AppColors.accentPurple.opacity(0.12)),
           Zone(name: "Work", timeRange: "9:30 AM – 1:00 PM", dotColor: AppColors.accentBlue, backgroundTint: AppColors.accentBlue.opacity(0.10)),
           Zone(name: "Personal", timeRange: "1:00 – 6:00 PM", dotColor: AppColors.warning, backgroundTint: AppColors.warning.opacity(0.12))
       ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: AppColors.skyGradientTop, location: 0.0),
                    .init(color: AppColors.skyGradientBottom, location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
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
