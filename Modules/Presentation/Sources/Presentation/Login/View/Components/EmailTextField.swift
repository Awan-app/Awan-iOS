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

    init(text: Binding<String>, errorMessage: String? = nil) {
        self._text = text
        self.errorMessage = errorMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EMAIL")
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(AppColors.brandDarkBlue)
                .kerning(1.2)

            TextField("", text: $text, prompt: Text("Enter your email").foregroundStyle(AppColors.textSecondary.opacity(0.5)))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(.body, design: .rounded, weight: .semibold))
                .padding()
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: AppColors.skyGradientTop, radius: 12, x: 0, y: 6)
                .overlay {
                    if errorMessage != nil {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppColors.destructive, lineWidth: 1.5)
                    }
                }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(.caption, design: .rounded, weight: .heavy))
                    .foregroundStyle(AppColors.destructive)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy, value: errorMessage)
    }
}
