//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import SwiftUI
import Common

struct GreetingHeader: View {
    let name: String
    let zoneCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Onboarding.goodMorningName(name))
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(AppColors.brandDarkBlue)
            
            Text(L10n.Onboarding.skySetupZones(zoneCount))
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GreetingHeader(name: "Sam", zoneCount: 4)
        .padding()
        .background(AppColors.screenBackground)
}
