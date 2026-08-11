import SwiftUI
import UIKit

/// A single-character text field that reliably reports backspace presses,
/// including when the field is already empty. This solves the common SwiftUI
/// OTP input bug where backspace on an empty `TextField` does not fire its
/// binding setter, leaving the user unable to delete and move backward.
struct OtpDigitField: UIViewRepresentable {
    var text: String
    var isFocused: Bool
    var isDisabled: Bool
    var textColor: UIColor
    var onDigitEntered: (String) -> Void
    var onBackspace: () -> Void
    var onBecameFocused: () -> Void

    func makeUIView(context: Context) -> OtpUITextField {
        let field = OtpUITextField()
        field.delegate = context.coordinator
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        field.textAlignment = .center
        field.font = UIFont.systemFont(ofSize: 22, weight: .black)
        field.tintColor = .clear
        field.backgroundColor = .clear
        return field
    }

    func updateUIView(_ uiView: OtpUITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = textColor
        uiView.isUserInteractionEnabled = !isDisabled
        uiView.onBackspace = { [onBackspace] in
            onBackspace()
        }
        uiView.onDelete = { [onBackspace] in
            onBackspace()
        }

        // Drive focus from SwiftUI state
        if isFocused, !uiView.isFirstResponder {
            // Delay slightly to avoid layout issues during SwiftUI update pass
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFocused, uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onDigitEntered: onDigitEntered,
            onBecameFocused: onBecameFocused
        )
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        let onDigitEntered: (String) -> Void
        let onBecameFocused: () -> Void

        init(
            onDigitEntered: @escaping (String) -> Void,
            onBecameFocused: @escaping () -> Void
        ) {
            self.onDigitEntered = onDigitEntered
            self.onBecameFocused = onBecameFocused
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            onBecameFocused()
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            // Let backspace through (handled by OtpUITextField.deleteBackward)
            guard !string.isEmpty else { return true }

            let filtered = string.filter { $0.isASCII && $0.isNumber }
            guard !filtered.isEmpty else { return false }

            onDigitEntered(filtered)
            return false
        }
    }
}

/// A UITextField subclass that reports backspace presses.
final class OtpUITextField: UITextField {
    var onBackspace: (() -> Void)?
    var onDelete: (() -> Void)?

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true
        if wasEmpty {
            onBackspace?()
        } else {
            text = ""
            onDelete?()
        }
    }
}
