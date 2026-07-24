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
    @State private var showOutsideHoursWarning: Bool = false
    @FocusState private var isNameFocused: Bool

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        let availableTime = viewModel.firstAvailableTimeInterval()
        _startTime = State(initialValue: availableTime.start)
        _endTime = State(initialValue: availableTime.end)
    }

    // MARK: - Computed

    private var selectedColor: (red: Double, green: Double, blue: Double, label: String) {
        ZoneColorPalette.colors[selectedColorIndex]
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
            .onAppear { validateOverlap() }
            .background(
                LinearGradient(
                    stops: [
                        .init(color: AppColors.skyGradientTop, location: 0.0),
                        .init(color: AppColors.skyGradientBottom, location: 0.5),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
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
        ZoneSheetHeader(
            iconName: "square.3.layers.3d.top.filled",
            title: L10n.Onboarding.addZoneTitle,
            selectedColor: selectedUIColor,
            bounceValue: selectedColorIndex
        )
    }

    // MARK: - Form Card

    private var formCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 20) {
                ZoneNameField(zoneName: $zoneName)
                ZoneColorPicker(selectedColorIndex: $selectedColorIndex)
                ZoneTimePickers(
                    startTime: $startTime,
                    endTime: $endTime,
                    isHorizontal: false,
                    onChange: validateOverlap
                )
            }
        }
    }

    // MARK: - Overlap Warning

    @ViewBuilder
    private var overlapWarning: some View {
        ZoneWarningsView(
            showOverlapError: showOverlapError,
            showOutsideHoursWarning: showOutsideHoursWarning
        )
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



    private func validateOverlap() {
        let start = OnboardingViewModel.formatTime(startTime)
        let end = OnboardingViewModel.formatTime(endTime)
        withAnimation(.snappy(duration: 0.2)) {
            showOverlapError = !startAfterEnd
                && viewModel.isTimeIntervalOverlapping(start: start, end: end)
            
            showOutsideHoursWarning = viewModel.isTimeIntervalOutsideActiveHours(start: startTime, end: endTime)
        }
    }
}
