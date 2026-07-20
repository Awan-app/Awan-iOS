//
//  EmailTextField.swift
//  Awan
//
//  Created by Manona on 18/07/2026.
//

import SwiftUI
import Common

struct EmailTextField: View {
    @Binding var text: String
    var errorState: AuthenticationErrorState?
    var isRateLimited: Bool
    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        errorState: AuthenticationErrorState? = nil,
        isRateLimited: Bool = false
    ) {
        self._text = text
        self.errorState = errorState
        self.isRateLimited = isRateLimited
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Login.emailLabel)
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(AppColors.brandDarkBlue)
                .kerning(1.2)

            TextField(
                "",
                text: $text,
                prompt: Text(L10n.Login.emailPrompt)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            )
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(.body, design: .rounded, weight: .semibold))
                .padding()
                .focused($isFocused)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            (hasInlineError && !isRateLimited) ? AppColors.destructive :
                                ((isFocused || !text.isEmpty) ? AppColors.accentBlue : AppColors.brandDarkBlue.opacity(0.15)),
                            lineWidth: 1.5
                        )
                }

            if let errorState {
                switch errorState {
                case .network:
                    NetworkErrorView(
                        message: L10n.Login.offlineError
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                case .inline(let message):
                    HStack(spacing: 4) {
                        Image(
                            systemName: isRateLimited
                                ? "clock.fill" : "exclamationmark.circle.fill"
                        )
                        .font(.system(size: 12))
                        Text(message)
                            .font(.system(.caption, design: .rounded, weight: .heavy))
                    }
                    .foregroundStyle(isRateLimited ? AppColors.warning : AppColors.destructive)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.snappy, value: errorState)
    }

    private var hasInlineError: Bool {
        guard case .inline = errorState else { return false }
        return true
    }
}
