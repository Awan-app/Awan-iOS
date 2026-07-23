import Common
import Domain
import SwiftUI

struct QuickAddTab: View {
    let zones: [Zone]
    let onSubmit: (String, Int, UUID?, Bool) -> Void

    @Binding var quickText: String
    @Binding var useSmartDuration: Bool
    @Binding var useBestZone: Bool
    @Binding var useAutoSchedule: Bool

    @State private var isListening: Bool = false
    @State private var waveformPhase: Double = 0.0
    @State private var isMascotFloating: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            sectionHeader
            taskInputCard
            orSeparator
            tellAwanVoiceCard
            chipsView
            AppButton(
                title: L10n.Home.btnPlanItForMe,
                icon: nil,
                color: AppColors.accentBlue,
                onTap: submitQuickAdd
            )
            .disabled(quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1.0)
        }
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Home.quickAddHeader.uppercased())
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Home.quickAddHeadline)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.Home.quickAddCaption)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 2)

                Image("info-cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 105, height: 105)
                    .layoutPriority(1)
                    .offset(y: isMascotFloating ? -6 : 6)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                        ) {
                            isMascotFloating = true
                        }
                    }
            }
        }
    }

    private var taskInputCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Home.fieldTask.uppercased())
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textSecondary)

            TextField(L10n.Schedule.questNamePlaceholder, text: $quickText, axis: .vertical)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.brandDarkBlue)
                .lineLimit(2...3)
                .textFieldStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColors.accentBlue.opacity(0.12), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.2), lineWidth: 1.5)
        )
    }

    private var orSeparator: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(AppColors.accentBlue.opacity(0.4))
                .frame(height: 1.5)

            Text(L10n.Home.orSeparator.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.accentBlue)

            Rectangle()
                .fill(AppColors.accentBlue.opacity(0.4))
                .frame(height: 1.5)
        }
        .padding(.vertical, 4)
    }

    private var tellAwanVoiceCard: some View {
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

    private var chipsView: some View {
        HStack(spacing: 6) {
            infoChip(
                title: L10n.Home.chipSmartDuration,
                icon: "sparkles"
            )
            infoChip(
                title: L10n.Home.chipBestZone,
                icon: "cloud"
            )
            infoChip(
                title: L10n.Home.chipAutoScheduled,
                icon: "arrow.up.right"
            )
        }
    }

    private func infoChip(title: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.accentBlue)

            Text(title)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.brandDarkBlue)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(
                    color: AppColors.accentBlue.opacity(0.12),
                    radius: 5, x: 0, y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.5), lineWidth: 1.5)
        )
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

    private func submitQuickAdd() {
        let title = quickText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        var duration = 60
        if useSmartDuration {
            let lower = title.lowercased()
            if lower.contains("2 hour") || lower.contains("2h") || lower.contains("ساعتين") {
                duration = 120
            } else if lower.contains("30 min") || lower.contains("half hour")
                || lower.contains("نصف ساعة")
            {
                duration = 30
            } else if lower.contains("3 hour") || lower.contains("3h") {
                duration = 180
            }
        }

        var zoneID: UUID? = nil
        if useBestZone {
            let lower = title.lowercased()
            zoneID =
                zones.first(where: { lower.contains($0.name.lowercased()) })?.id ?? zones.first?.id
        }

        onSubmit(title, duration, zoneID, useAutoSchedule)
    }
}
