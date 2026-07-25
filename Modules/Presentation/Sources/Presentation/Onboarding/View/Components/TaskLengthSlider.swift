//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 20/07/2026.
//

import SwiftUI
import Common

struct TaskLengthSlider: View {
    @Binding var focusDurationIndex: Int
    let labels: [String]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(AppColors.outline)
                        .frame(height: 8)

                    // Fill
                    Capsule()
                        .fill(AppColors.accentBlue)
                        .frame(
                            width: max(
                                8,
                                (geometry.size.width - 24)
                                    * CGFloat(focusDurationIndex)
                                    / CGFloat(labels.count - 1) + 12), height: 8)

                    // Thumb
                    Circle()
                        .fill(AppColors.surface)
                        .frame(width: 28, height: 28)
                        .shadow(
                            color: AppColors.shadow.opacity(0.15), radius: 4, x: 0,
                            y: 2
                        )
                        .overlay(
                            Circle().stroke(AppColors.accentBlue, lineWidth: 2)
                        )
                        .offset(
                            x: (geometry.size.width - 28)
                                * CGFloat(focusDurationIndex)
                                / CGFloat(labels.count - 1)
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let stepWidth =
                                        (geometry.size.width - 28)
                                        / CGFloat(labels.count - 1)
                                    let newValue = Int(
                                        round(gesture.location.x / stepWidth))
                                    withAnimation(.interactiveSpring()) {
                                        focusDurationIndex = min(
                                            max(0, newValue), labels.count - 1)
                                    }
                                }
                        )
                }

                // Labels
                ZStack {
                    ForEach(0..<labels.count, id: \.self) { index in
                        Text(labels[index])
                            .font(AppFonts.caption2Bold)
                            .foregroundColor(
                                focusDurationIndex == index
                                    ? AppColors.accentBlue : AppColors.textSecondary
                            )
                            .offset(
                                x: (CGFloat(index) / CGFloat(labels.count - 1) - 0.5)
                                    * (geometry.size.width - 28))
                    }
                }
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 32)
        .padding(.top, 24)
    }
}
#Preview {
    TaskLengthSlider(focusDurationIndex: .constant(5), labels: ["15m", "30m", "45m", "1h", "1.5h", "2h", "2.5h", "3h"])
}


#Preview {
    TaskLengthSlider(focusDurationIndex: .constant(0), labels: ["Short", "Medium", "Long"])
        .padding()
}

