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
    var errorMessage: String?
    var isOffline: Bool
    var isRateLimited: Bool
    @FocusState private var isFocused: Bool

    init(text: Binding<String>, errorMessage: String? = nil, isOffline: Bool = false, isRateLimited: Bool = false) {
        self._text = text
        self.errorMessage = errorMessage
        self.isOffline = isOffline
        self.isRateLimited = isRateLimited
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EMAIL")
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(AppColors.brandDarkBlue)
                .kerning(1.2)

            TextField("", text: $text, prompt: Text("Enter your email").foregroundStyle(AppColors.textSecondary.opacity(0.5)))
#if os(iOS)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
#endif
                .autocorrectionDisabled()
                .font(.system(.body, design: .rounded, weight: .semibold))
                .padding()
                .focused($isFocused)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            (errorMessage != nil && !isRateLimited) ? AppColors.destructive :
                                ((isFocused || !text.isEmpty) ? AppColors.accentBlue : AppColors.brandDarkBlue.opacity(0.15)),
                            lineWidth: 1.5
                        )
                }

            if isOffline {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("You're offline — we'll send the code when you reconnect.")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.brandDarkBlue)
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if let errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: isRateLimited ? "clock.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(.system(.caption, design: .rounded, weight: .heavy))
                }
                .foregroundStyle(isRateLimited ? .orange : AppColors.destructive)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy, value: errorMessage)
        .animation(.snappy, value: isOffline)
    }
}
