import SwiftUI
import Common
import UIKit

public struct TaskItem: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

struct TaskPreviewCard: View {
    let tasks: [TaskItem]
    var onDelete: ((TaskItem) -> Void)?
    
    private let depth: CGFloat = 4
    
    var body: some View {
        ZStack {
            // Bottom Layer — depth shape, slightly larger on all sides so it peeks
            // out around the entire card (not just the bottom edge)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.accentBlueDepth.opacity(0.10))
                .padding(.horizontal, -depth)
                .padding(.top, -depth)
                .padding(.bottom, -depth * 2)
            
            // Top Layer — the actual card content
            VStack(alignment: .leading, spacing: 16) {
                Text("...AND IT LANDS IN YOUR DAY")
                    .font(AppFonts.captionHeavy)
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 8) {
                    Text("Study")
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.accentPurple)
                    
                    Text("7:00 – 9:30 AM")
                        .font(AppFonts.caption2Bold)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if !tasks.isEmpty {
                    ForEach(tasks) { task in
                        HStack(spacing: 12) {
                            Circle()
                                .stroke(AppColors.outline, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(AppFonts.subheadlineBold)
                                    .foregroundColor(AppColors.brandDarkBlue)
                                    .lineLimit(1)
                                
                                Text("60 min · Study")
                                    .font(AppFonts.captionHeavy)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if task == tasks.last {
                                Text("NEW")
                                    .font(AppFonts.caption2Bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.accentPurple)
                                    )
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    onDelete?(task)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.textSecondary)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.accentPurple, lineWidth: 2)
                        )
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                } else {
                    Spacer(minLength: 140)
                }
                
                Text("I'll do one happy bounce as it settles in.")
                    .font(AppFonts.captionHeavy)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: AppColors.accentBlue.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: tasks)
    }
}

#Preview {
    ZStack {
        AppColors.screenBackground.ignoresSafeArea()
        TaskPreviewCard(tasks: [])
            .padding()
    }
}
