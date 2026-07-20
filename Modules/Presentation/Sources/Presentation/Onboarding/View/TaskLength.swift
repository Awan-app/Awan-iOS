//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import SwiftUI

struct TaskLength: View {
    @Environment(OnboardingCoordinator.self) private var coordinator
    @State private var sliderValue: Int = 2

    let labels = ["30", "45", "60", "90", "120", "3h"]

    var focusDurationText: String {
        switch sliderValue {
        case 0: return "About 30 minutes"
        case 1: return "About 45 minutes"
        case 2: return "About 1 hour"
        case 3: return "About 1.5 hours"
        case 4: return "About 2 hours"
        case 5: return "About 3 hours"
        default: return "About 1 hour"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()

                Button(action: {
                    // Skip action
                }) {
                    Text("Skip")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.accentBlue)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            OnboardingProgressBar(currentStep: 4, totalSteps: 7)
                .padding(.horizontal, 24)
                .padding(.top, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Title Area
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How long do you like to focus in one go?")
                            .font(AppFonts.nudgeSymbol)
                            .foregroundColor(AppColors.brandDarkBlue)
                            .lineSpacing(4)

                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(AppFonts.hourLabel)
                            Text("You can change this anytime")
                                .font(AppFonts.captionHeavy)
                        }
                        .foregroundColor(AppColors.accentBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.accentBlue.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    // Main Value Display
                    VStack(spacing: 8) {
                        Text(focusDurationText)
                            .font(AppFonts.nudgeSymbol)
                            .foregroundColor(AppColors.brandDarkBlue)

                        Text("preferred focus block")
                            .font(AppFonts.subheadlineBold)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 10)

                    // Custom Slider
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
                                            (geometry.size.width - 24) * CGFloat(sliderValue)
                                                / CGFloat(labels.count - 1) + 12), height: 8)

                                // Thumb
                                Circle()
                                    .fill(AppColors.surface)
                                    .frame(width: 28, height: 28)
                                    .shadow(
                                        color: AppColors.shadow.opacity(0.15), radius: 4, x: 0, y: 2
                                    )
                                    .overlay(
                                        Circle().stroke(AppColors.accentBlue, lineWidth: 2)
                                    )
                                    .offset(
                                        x: (geometry.size.width - 28) * CGFloat(sliderValue)
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
                                                    sliderValue = min(
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
                                            sliderValue == index
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

                    // Explanation Text
                    (Text(
                        "Longer means fewer, deeper blocks; shorter means\nmore, lighter ones. Anything longer gets "
                    )
                    .font(AppFonts.captionHeavy)
                    .foregroundColor(AppColors.textSecondary)
                        + Text("split into\nlinked sessions.")
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.brandDarkBlue))
                        .lineSpacing(4)
                    // How blocks feel section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("HOW BLOCKS FEEL")
                            .font(AppFonts.hourLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .kerning(1.5)

                        HStack(spacing: 12) {
                            BlockFeelOptionView(
                                title: "30m", subtitle: "short & light", numberOfBlocks: 3,
                                isSelected: sliderValue == 0
                            )
                            .onTapGesture { withAnimation { sliderValue = 0 } }
                            BlockFeelOptionView(
                                title: "1h", subtitle: "balanced", numberOfBlocks: 2,
                                isSelected: sliderValue == 2
                            )
                            .onTapGesture { withAnimation { sliderValue = 2 } }
                            BlockFeelOptionView(
                                title: "3h", subtitle: "deep & few", numberOfBlocks: 1,
                                isSelected: sliderValue == 5
                            )
                            .onTapGesture { withAnimation { sliderValue = 5 } }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                }
                .padding(.bottom, 24)
            }

            // Continue Button
            OnboardingContinueButton(title: "CONTINUE") {
                coordinator.push(.taskSimulation)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

        }
        .background(AppColors.screenBackground.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    TaskLength()
        .environment(OnboardingCoordinator())
}
