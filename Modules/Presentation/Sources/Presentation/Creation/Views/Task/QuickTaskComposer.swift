import Common
import SwiftUI

struct QuickTaskComposer: View {
    @Binding var text: String
    let isRecording: Bool
    var placeholder = L10n.Schedule.questNamePlaceholder
    var sendAccessibilityLabel = L10n.Home.btnPlanItForMe
    var recordingAccessibilityLabel = L10n.Home.tellAwan
    let onSend: () -> Void
    let onRecordingStarted: () -> Void
    let onRecordingEnded: () -> Void

    @State private var isHoldingMicrophone = false

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            AppTextField(
                text: $text,
                placeholder: placeholder,
                axis: .vertical,
                lineLimit: 1...3,
                submitLabel: .send
            ) {
                if hasText {
                    onSend()
                }
            }
            .disabled(isRecording)

            if hasText {
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                }
                .buttonStyle(
                    ComposerActionButtonStyle(color: AppColors.accentBlue)
                )
                .accessibilityLabel(sendAccessibilityLabel)
            } else {
                actionFace(
                    icon: "mic.fill",
                    isPressed: isHoldingMicrophone || isRecording
                )
                .contentShape(Circle())
                .gesture(recordingGesture)
                .accessibilityElement()
                .accessibilityLabel(recordingAccessibilityLabel)
                .accessibilityAddTraits(.isButton)
            }
        }
        .animation(.snappy(duration: 0.18), value: hasText)
    }

    private var recordingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isHoldingMicrophone else { return }
                isHoldingMicrophone = true
                onRecordingStarted()
            }
            .onEnded { _ in
                isHoldingMicrophone = false
                onRecordingEnded()
            }
    }

    private func actionFace(icon: String, isPressed: Bool) -> some View {
        Image(systemName: icon)
            .font(.system(size: 20, weight: .heavy))
            .foregroundStyle(AppColors.onAccent)
            .frame(width: 52, height: 52)
            .background(
                (isRecording ? AppColors.destructive : AppColors.accentBlue).gradient,
                in: Circle()
            )
            .overlay {
                Circle()
                    .stroke(AppColors.onAccent.opacity(0.25), lineWidth: 1.5)
            }
            .shadow(
                color: (isRecording ? AppColors.destructive : AppColors.accentBlue)
                    .opacity(0.75),
                radius: 0,
                y: isPressed ? 1 : 5
            )
            .offset(y: isPressed ? 4 : 0)
            .padding(.bottom, 5)
            .animation(.snappy(duration: 0.18), value: isPressed)
            .animation(.snappy(duration: 0.18), value: isRecording)
    }
}

private struct ComposerActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .heavy))
            .foregroundStyle(AppColors.onAccent)
            .frame(width: 52, height: 52)
            .background(color.gradient, in: Circle())
            .overlay {
                Circle()
                    .stroke(AppColors.onAccent.opacity(0.25), lineWidth: 1.5)
            }
            .shadow(
                color: color.opacity(0.75),
                radius: 0,
                y: configuration.isPressed ? 1 : 5
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .padding(.bottom, 5)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}


#Preview {
    QuickTaskComposer(text: .constant(""), isRecording: false, onSend: {}, onRecordingStarted: {}, onRecordingEnded: {})
        .padding()
}

