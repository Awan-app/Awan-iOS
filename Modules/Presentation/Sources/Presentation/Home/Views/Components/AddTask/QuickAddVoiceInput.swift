import Common
import SwiftUI

struct QuickAddVoiceInput: View {
    @Binding var quickText: String
    
    @State private var isListening: Bool = false
    @State private var waveformPhase: Double = 0.0

    var body: some View {
        Button(action: toggleVoiceInput) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 16) {
                    // Circular Mic Icon Button
                    ZStack {
                        Circle()
                            .fill(isListening ? AppColors.destructive : AppColors.accentBlue)
                            .frame(width: 56, height: 56)
                            .shadow(color: (isListening ? AppColors.destructive : AppColors.accentBlue).opacity(0.4), radius: 8, x: 0, y: 4)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isListening ? L10n.Home.listeningState : L10n.Home.tellAwan)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.brandDarkBlue)

                        Text(L10n.Home.tapToSpeak)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    waveformIndicator
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: AppColors.accentBlue.opacity(0.15), radius: 12, x: 0, y: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppColors.accentBlue.opacity(0.4), lineWidth: 1.5)
                )

                Image("voice-cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 82)
                    .offset(x: 10, y: -28)
            }
        }
        .buttonStyle(.plain)
    }

    private var waveformIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isListening ? AppColors.destructive : AppColors.accentBlue.opacity(0.7))
                    .frame(
                        width: 3.5,
                        height: isListening
                            ? CGFloat(12 + sin(waveformPhase + Double(index) * 0.8) * 10)
                            : 12 + CGFloat(index % 3) * 4
                    )
            }
        }
        .frame(height: 24)
        .onAppear {
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: true)) {
                waveformPhase = .pi * 2
            }
        }
    }

    private func toggleVoiceInput() {
        if isListening {
            isListening = false
        } else {
            isListening = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                if isListening {
                    isListening = false
                    quickText = "Prepare presentation for 2 hours"
                }
            }
        }
    }
}
