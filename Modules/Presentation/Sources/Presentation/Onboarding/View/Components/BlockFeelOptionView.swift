import SwiftUI
import Common

struct BlockFeelOptionView: View {
    let title: String
    let subtitle: String
    let numberOfBlocks: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.brandDarkBlue)
                
                Text(subtitle)
                    .font(AppFonts.caption2Bold)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<numberOfBlocks, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppColors.accentBlue)
                        .frame(height: 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppColors.accentBlue : AppColors.outline, lineWidth: isSelected ? 2 : 1)
        )
    }
}
