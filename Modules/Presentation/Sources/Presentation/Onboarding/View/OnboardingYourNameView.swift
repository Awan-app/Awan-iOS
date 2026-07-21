//
//  OnboardingYourNameView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

struct OnboardingYourNameView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    @FocusState private var focusedField: NameField?
    @State private var animatePreviewLogo = false

    private enum NameField {
        case firstName
        case lastName
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        ChangeAnytimeTag()
                        nameFieldsSection
                        previewSection
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    // MARK: - Sections

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Onboarding.nameTitle)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.brandDarkBlue)

                Text(L10n.Onboarding.nameSubtitle)
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
                Text(L10n.Onboarding.firstNameLabel)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .kerning(1)

                TextField(L10n.Onboarding.firstNamePlaceholder, text: $viewModel.firstName)
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
                Text(L10n.Onboarding.lastNameLabel)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .kerning(1)

                TextField(L10n.Onboarding.lastNamePlaceholder, text: $viewModel.lastName)
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
                Text(L10n.Onboarding.previewLabel)
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
            title: L10n.Common.continue,
            icon: nil,
            color: AppColors.accentBlue,
            foregroundColor: AppColors.onAccent,
            size: .large,
            onTap: {
                guard viewModel.isNameValid else { return }
                onContinue()
            }
        )
        .disabled(!viewModel.isNameValid)
        .opacity(viewModel.isNameValid ? 1.0 : 0.5)
    }
}

#Preview {
    OnboardingYourNameView(viewModel: .preview, onContinue: {})
}
