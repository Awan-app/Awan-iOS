//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 17/07/2026.
//

import Common
import Domain
import SwiftUI

struct OtpVerificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var myOtp : String = ""
    @State private var viewModel: OtpVerificationViewModel

    init(viewModel: OtpVerificationViewModel) {
        self.viewModel = viewModel
    }

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
                    Text("Enter the code we sent to")
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(viewModel.email)
                            .font(AppFonts.subheadlineBold)
                            .foregroundColor(AppColors.accentBlue)
                    
                }
                .padding(.bottom, 32)

                // OTP Fields
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            let char = getChar(at: index)
                            Text(viewModel.state == .success ? "" : char)
                                .font(AppFonts.title3Black)
                                .foregroundColor(
                                    viewModel.state == .failure
                                        ? AppColors.destructive : AppColors.textPrimary
                                )
                                .frame(width: 44, height: 52)
                                .background(AppColors.otpWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            viewModel.state == .failure
                                                ? AppColors.destructive : AppColors.accentBlue,
                                            lineWidth: 1.5)
                                )
                        }
                    }
                    .overlay {
                        // Invisible text field to capture input
                        TextField("", text: $myOtp)
                            .keyboardType(.numberPad)
                            .opacity(0)
                            .disabled(viewModel.state == .verifying)
                    }
                    .onChange(of: myOtp) { oldValue, newValue in
                        viewModel.code = newValue
                    }
                    
                    Spacer().frame(height: 5)
                    // Verification status
                    if viewModel.state == .verifying || viewModel.state == .success {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, AppColors.accentBlue)
                                .font(.system(size: 20, weight: .black))
                                .shadow(color: AppColors.accentBlue.opacity(0.6), radius: 0, x: 0, y: 2)
    
                            HStack(spacing: 0) {
                                Text("Verified — drifting you in")
                                    .font(AppFonts.subheadlineBold)
                                    .foregroundColor(AppColors.accentBlue)
    
                                TypingDotsView()
                                    .padding(.leading, 2)
                                    .padding(.bottom, 1)
                            }
                        }
                    }

                    if viewModel.state == .failure {
                        OtpFailureAlertView()
                            .padding(.top, 4)
                    } else {
                        Spacer().frame(height: 24)
                    }
                }
                .padding(.bottom, 16)

                Spacer()

                // Bottom Section
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.resendCode()
                        myOtp = ""
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(AppFonts.captionHeavy)
                            Text("RESEND CODE")
                                .font(AppFonts.captionHeavy)
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .disabled(viewModel.state == .verifying)
                    .opacity(viewModel.state == .verifying ? 0.5 : 1.0)

                    Text("Numeric keypad · auto-submits on the 6th digit")
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 32)
            }
        }
        .alert("Error", isPresented: Bindable(viewModel).isShowingErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.resetError()
                myOtp = ""
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    private func getChar(at index: Int) -> String {
        guard index < myOtp.count else { return "" }
        let charIndex = myOtp.index(myOtp.startIndex, offsetBy: index)
        return String(myOtp[charIndex])
    }
}


