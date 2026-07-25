import SwiftUI

public struct AppTextField: View {
    @Binding private var text: String

    private let placeholder: String
    private let axis: Axis
    private let lineLimit: ClosedRange<Int>
    private let submitLabel: SubmitLabel
    private let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int> = 1...1,
        submitLabel: SubmitLabel = .done,
        onSubmit: @escaping () -> Void = {}
    ) {
        _text = text
        self.placeholder = placeholder
        self.axis = axis
        self.lineLimit = lineLimit
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }

    public var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5)),
            axis: axis
        )
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .foregroundStyle(AppColors.brandDarkBlue)
        .lineLimit(lineLimit)
        .textFieldStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .focused($isFocused)
        .submitLabel(submitLabel)
        .onSubmit(onSubmit)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(depthColor)
                    .offset(y: 5)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.surface)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    borderColor,
                    lineWidth: isFocused ? 2 : 1.5
                )
        }
        .padding(.bottom, 5)
        .animation(.snappy(duration: 0.18), value: isFocused)
    }

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var borderColor: Color {
        isFocused || hasText
            ? AppColors.accentBlue
            : AppColors.brandDarkBlue.opacity(0.15)
    }

    private var depthColor: Color {
        isFocused
            ? borderColor
            : AppColors.accentBlueDepth.opacity(0.55)
    }
}

#Preview {
    @Previewable @State var text = ""

    AppTextField(
        text: $text,
        placeholder: "What will you conquer?",
        axis: .vertical,
        lineLimit: 1...3,
        submitLabel: .send
    )
    .padding()
    .background(AppColors.screenBackground)
}
