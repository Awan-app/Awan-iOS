//
//  OnboardingYourNameView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct OnboardingYourNameView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var focusedField: NameField?
    @State private var animatePreviewLogo = false

    private enum NameField {
        case firstName
        case lastName
    }

    var body: some View {
        ZStack {
            // 1. Background Layer (Fixed, won't shift with keyboard)
            LinearGradient(
                stops: [
                    .init(color: AppColors.skyGradientTop, location: 0.0),
                    .init(color: AppColors.skyGradientBottom, location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 2. Content Layer
            VStack(spacing: 0) {
                OnboardingStepHeader(
                    currentStep: 1,
                    totalSteps: viewModel.totalSteps,
                    onSkip: { viewModel.skipOnboarding() }
                )
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        ChangeAnytimeTag()
                        nameFieldsSection
                        previewSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            
                // Bottom Action Area
                VStack {
                    continueButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            focusedField = .firstName
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What should I call you?")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.brandDarkBlue)

                Text("Just your name — I'll use it to greet you each morning.")
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 12)

            Image("login-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
        }
    }

    private var nameFieldsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("FIRST NAME")
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .kerning(1)

                TextField("Sam", text: $viewModel.firstName)
                    .font(AppFonts.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        AppColors.surface,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                focusedField == .firstName
                                    ? AppColors.accentBlue
                                    : AppColors.outline.opacity(0.12),
                                lineWidth: focusedField == .firstName ? 2 : 1
                            )
                    }
                    .focused($focusedField, equals: .firstName)
                    .textContentType(.givenName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .lastName }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("LAST NAME")
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .kerning(1)

                TextField("Rivera", text: $viewModel.lastName)
                    .font(AppFonts.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        AppColors.surface,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                focusedField == .lastName
                                    ? AppColors.accentBlue
                                    : AppColors.outline.opacity(0.12),
                                lineWidth: focusedField == .lastName ? 2 : 1
                            )
                    }
                    .focused($focusedField, equals: .lastName)
                    .textContentType(.familyName)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
            }
        }
    }

    private var previewSection: some View {
        HStack(spacing: 10) {
            Image("login-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .offset(y: animatePreviewLogo ? 0 : -20)
                .onAppear {
                    withAnimation(.interpolatingSpring(stiffness: 150, damping: 5).delay(0.2)) {
                        animatePreviewLogo = true
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("PREVIEW")
                    .font(AppFonts.microHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .kerning(0.5)

                Text(viewModel.greetingPreview)
                    .font(AppFonts.subheadlineBlack)
                    .foregroundStyle(AppColors.brandDarkBlue)
            }
        }
        .padding(.top, 8)
    }

    private var continueButton: some View {
        AppButton(
            title: "CONTINUE",
            icon: nil,
            color: viewModel.isNameValid
                ? AppColors.accentBlue
                : AppColors.skyGradientTop.opacity(0.4),
            foregroundColor: viewModel.isNameValid
                ? AppColors.onAccent
                : AppColors.brandDarkBlue.opacity(0.5),
            shadowColor: viewModel.isNameValid ? nil : .clear,
            size: .large,
            onTap: {
                guard viewModel.isNameValid else { return }
                appCoordinator.onboardingCoordinator.push(.wakeSleep)
            }
        )
        .disabled(!viewModel.isNameValid)
    }
}

#Preview {
    OnboardingYourNameView(viewModel: .preview)
        .environment(AppCoordinator())
}
