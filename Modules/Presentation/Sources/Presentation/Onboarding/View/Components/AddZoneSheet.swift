//
//  AddZoneSheet.swift
//  Presentation
//
//  Created by Awan Agent on 22/07/2026.
//

import Common
import SwiftUI

struct AddZoneSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: OnboardingViewModel

    @State private var zoneName: String = ""
    @State private var selectedColorIndex: Int = 0
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var showOverlapError: Bool = false
    @FocusState private var isNameFocused: Bool

    // MARK: - Predefined palette

    private static let colorPalette: [(red: Double, green: Double, blue: Double, label: String)] = [
        (0.30, 0.70, 0.70, "Teal"),
        (0.30, 0.50, 0.80, "Blue"),
        (0.90, 0.60, 0.30, "Orange"),
        (0.85, 0.40, 0.50, "Pink"),
        (0.55, 0.35, 0.80, "Purple"),
        (0.35, 0.75, 0.45, "Green"),
        (0.90, 0.35, 0.35, "Red"),
        (0.95, 0.75, 0.30, "Yellow")
    ]

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        let availableTime = viewModel.firstAvailableTimeInterval()
        _startTime = State(initialValue: availableTime.start)
        _endTime = State(initialValue: availableTime.end)
    }

    // MARK: - Computed

    private var selectedColor: (red: Double, green: Double, blue: Double, label: String) {
        Self.colorPalette[selectedColorIndex]
    }

    private var selectedUIColor: Color {
        Color(red: selectedColor.red, green: selectedColor.green, blue: selectedColor.blue)
    }

    private var isFormValid: Bool {
        let trimmed = zoneName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !startAfterEnd else { return false }
        let start = OnboardingViewModel.formatTime(startTime)
        let end = OnboardingViewModel.formatTime(endTime)
        return !viewModel.isTimeIntervalOverlapping(start: start, end: end)
    }

    private var startAfterEnd: Bool {
        startTime >= endTime
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    sheetHeader
                    formCard
                    overlapWarning
                    addButton
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.close) { dismiss() }
                        .font(AppFonts.bodyBold)
                }
            }
        }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.3.layers.3d.top.filled")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(selectedUIColor)
                .symbolEffect(.bounce, value: selectedColorIndex)
            Text(L10n.Onboarding.addZoneTitle)
                .font(AppFonts.title2Black)
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 20) {
                nameField
                colorPicker
                timePickers
            }
        }
    }

    // MARK: - Name Field

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Onboarding.zoneNameLabel)
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(AppColors.brandDarkBlue)
                .kerning(1.2)

            TextField(
                "",
                text: $zoneName,
                prompt: Text(L10n.Onboarding.zoneNamePlaceholder)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .font(.system(.body, design: .rounded, weight: .semibold))
            .padding()
            .focused($isNameFocused)
            .background(
                AppColors.surface,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        (isNameFocused || !zoneName.isEmpty)
                            ? AppColors.accentBlue
                            : AppColors.brandDarkBlue.opacity(0.15),
                        lineWidth: 1.5
                    )
            }
            .accessibilityIdentifier("zone-name-field")
        }
    }

    // MARK: - Color Picker

    private var colorPicker: some View {
        labeledField(L10n.Onboarding.zoneColorLabel, icon: "paintpalette.fill") {
            HStack(spacing: 10) {
                ForEach(Self.colorPalette.indices, id: \.self) { index in
                    let palette = Self.colorPalette[index]
                    let color = Color(red: palette.red, green: palette.green, blue: palette.blue)
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedColorIndex = index
                        }
                    } label: {
                        Circle()
                            .fill(color.gradient)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if selectedColorIndex == index {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(.white)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .overlay {
                                Circle()
                                    .stroke(
                                        selectedColorIndex == index
                                            ? color.opacity(0.8)
                                            : Color.clear,
                                        lineWidth: 2.5
                                    )
                                    .frame(width: 36, height: 36)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(palette.label)
                    .accessibilityIdentifier("zone-color-\(index)")
                }
            }
        }
    }

    // MARK: - Time Pickers

    private var timePickers: some View {
        VStack(alignment: .leading, spacing: 14) {
            labeledField(L10n.Onboarding.zoneStartTime, icon: "clock") {
                DatePicker(
                    "",
                    selection: $startTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .onChange(of: startTime) { validateOverlap() }
                .accessibilityIdentifier("zone-start-picker")
            }

            labeledField(L10n.Onboarding.zoneEndTime, icon: "clock.badge.checkmark") {
                DatePicker(
                    "",
                    selection: $endTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .onChange(of: endTime) { validateOverlap() }
                .accessibilityIdentifier("zone-end-picker")
            }

            if startAfterEnd {
                Label("End time must be after start time", systemImage: "exclamationmark.triangle.fill")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.destructive)
            }
        }
    }

    // MARK: - Overlap Warning

    @ViewBuilder
    private var overlapWarning: some View {
        if showOverlapError {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(L10n.Onboarding.zoneOverlapError)
                    .font(AppFonts.subheadlineBold)
            }
            .foregroundStyle(AppColors.destructive)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppColors.destructive.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        AppButton(
            title: L10n.Onboarding.addZone,
            icon: "plus.circle.fill",
            color: isFormValid ? AppColors.accentBlue : AppColors.buttonDisabled,
            foregroundColor: AppColors.onAccent,
            shadowColor: isFormValid ? nil : AppColors.buttonDisabledDepth,
            onTap: {
                guard isFormValid else { return }
                let color = selectedColor
                let zone = SuggestedZone(
                    id: UUID(),
                    name: zoneName.trimmingCharacters(in: .whitespacesAndNewlines),
                    startTime: OnboardingViewModel.formatTime(startTime),
                    endTime: OnboardingViewModel.formatTime(endTime),
                    colorRed: color.red,
                    colorGreen: color.green,
                    colorBlue: color.blue
                )
                withAnimation(.snappy(duration: 0.25)) {
                    viewModel.addZone(zone)
                }
                dismiss()
            }
        )
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1 : 0.55)
        .accessibilityIdentifier("save-zone-button")
    }

    // MARK: - Helpers

    private func labeledField<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textSecondary)
            content()
        }
    }

    private func validateOverlap() {
        let start = OnboardingViewModel.formatTime(startTime)
        let end = OnboardingViewModel.formatTime(endTime)
        withAnimation(.snappy(duration: 0.2)) {
            showOverlapError = !startAfterEnd
                && viewModel.isTimeIntervalOverlapping(start: start, end: end)
        }
    }
}
