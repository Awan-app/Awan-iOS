//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 17/07/2026.
//

import SwiftUI
import Common

struct OtpVerificationView: View {
    @State private var otp: String = "428019"
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [AppColors.otpTopColor, AppColors.otpWhite],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(AppFonts.subheadlineHeavy)
                            Text("BACK")
                                .font(AppFonts.subheadlineHeavy)
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                    .frame(height: 48)
                
                // Cloud Icon
                AppImages.otpCloudIcon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 24)
                
                // Title
                Text("You're in! ☀️")
                    .font(AppFonts.title2Black)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 12)
                
                // Subtitle
                VStack(spacing: 4) {
                    Text("We floated a code to")
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button(action: {}) {
                        Text("Edit")
                            .font(AppFonts.subheadlineBold)
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
                .padding(.bottom, 32)
                
                // OTP Fields
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        let char = getChar(at: index)
                        Text(char)
                            .font(AppFonts.title3Black)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 52)
                            .background(AppColors.otpWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.accentBlue, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.bottom, 16)
                
                // Verification status
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, AppColors.accentBlue)
                        .font(.system(size: 20, weight: .black))
                        .shadow(color: AppColors.accentBlue.opacity(0.6), radius: 0, x: 0, y: 2)
                    Text("Verified — drifting you in...")
                        .font(AppFonts.subheadlineBold)
                        .foregroundColor(AppColors.accentBlue)
                }
                
                Spacer()
                
                // Bottom Section
                VStack(spacing: 12) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(AppFonts.captionHeavy)
                            Text("RESEND CODE")
                                .font(AppFonts.captionHeavy)
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    
                    Text("Numeric keypad · auto-submits on the 6th digit")
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 32)
            }
            .toolbar(.hidden)
        }
    }
    
    private func getChar(at index: Int) -> String {
        guard index < otp.count else { return "" }
        let stringIndex = otp.index(otp.startIndex, offsetBy: index)
        return String(otp[stringIndex])
    }
}

#Preview {
    OtpVerificationView()
}
