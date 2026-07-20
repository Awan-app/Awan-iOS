import SwiftUI
import Common
import UIKit

struct TaskSimulation: View {
    @State private var taskText: String = ""
    @State private var addedTasks: [TaskItem] = []
    @FocusState private var isFocused: Bool
    
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
                // Top Bar progress
                OnboardingProgressBar(currentStep: 5, totalSteps: 7)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                // Scrollable content — everything EXCEPT the bottom action area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 16) {
                            AuthCloudLogoView()
                            
                            VStack(spacing: 8) {
                                Text("Let's add your first thing for today")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(AppColors.brandDarkBlue)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Input Section
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text("Try \"Go for a run\", \"Call Mum\", or \"Reading book\".")
                                .font(AppFonts.captionHeavy)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 16)
                                
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.accentBlueDepth.opacity(0.10))
                                    .padding(.horizontal, -4)
                                    .padding(.top, -4)
                                    .padding(.bottom, -8)
                                
                                TextField("e.g. Go for a run", text: $taskText)
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(AppColors.brandDarkBlue)
                                    .padding(16)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(AppColors.accentBlue, lineWidth: isFocused ? 3 : 1)
                                    )
                                    .focused($isFocused)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                        
                        TaskPreviewCard(
                            tasks: addedTasks,
                            onDelete: { taskToDelete in
                                addedTasks.removeAll(where: { $0.id == taskToDelete.id })
                            }
                        )
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                    // Extra bottom clearance so the last task row never sits
                    // underneath the fixed bottom action area below
                    .padding(.bottom, 140)
                }
                
                // Bottom Action Area — OUTSIDE the ScrollView, always pinned in place
                VStack(spacing: 16) {
                    OnboardingContinueButton(
                        title: "ADD IT",
                        isEnabled: !taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        let trimmed = taskText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                addedTasks.append(TaskItem(title: trimmed))
                                taskText = ""
                            }
                        }
                    }
                    
                    SkipForNowLink {
                        // Skip action
                    }
                }
                .padding(.horizontal, 24)
                .background(.clear)
            }
        }
    }
}

#Preview {
    TaskSimulation()
}
