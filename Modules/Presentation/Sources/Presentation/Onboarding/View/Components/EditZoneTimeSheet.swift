//
//  EditZoneTimeSheet.swift
//  Presentation
//
//  Created by Awan Agent on 22/07/2026.
//

import Common
import SwiftUI
import Domain

struct EditZoneTimeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: OnboardingViewModel
    let zone: SuggestedZone

    @State private var zoneName: String
    @State private var selectedColorIndex: Int
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var showOverlapError: Bool = false
    @State private var showOutsideHoursWarning: Bool = false
    @FocusState private var isNameFocused: Bool

    init(viewModel: OnboardingViewModel, zone: SuggestedZone) {
        self.viewModel = viewModel
        self.zone = zone
        
        _zoneName = State(initialValue: zone.name)
        
        let initialColorIndex = ZoneColorPalette.colors.firstIndex(where: {
            abs($0.red - zone.colorRed) < 0.01 &&
            abs($0.green - zone.colorGreen) < 0.01 &&
            abs($0.blue - zone.colorBlue) < 0.01
        }) ?? 0
        _selectedColorIndex = State(initialValue: initialColorIndex)
        
        _startTime = State(initialValue: OnboardingViewModel.parseTime(zone.startTime) ?? .now)
        _endTime = State(initialValue: OnboardingViewModel.parseTime(zone.endTime) ?? .now)
    }

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
        return !viewModel.isTimeIntervalOverlapping(start: start, end: end, excludingID: zone.id)
    }

    private var startAfterEnd: Bool {
        startTime >= endTime
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    sheetHeader
                    formCard
                    overlapWarning
                    saveButton
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

    private var sheetHeader: some View {
        ZoneSheetHeader(
            iconName: "square.and.pencil",
            title: L10n.Onboarding.editZone,
            selectedColor: selectedUIColor,
            bounceValue: selectedColorIndex
        )
    }

    private var formCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 20) {
                ZoneNameField(zoneName: $zoneName)
                ZoneColorPicker(selectedColorIndex: $selectedColorIndex)
                ZoneTimePickers(
                    startTime: $startTime,
                    endTime: $endTime,
                    isHorizontal: true,
                    onChange: validateOverlap
                )
            }
        }
    }

    @ViewBuilder
    private var overlapWarning: some View {
        ZoneWarningsView(
            showOverlapError: showOverlapError,
            showOutsideHoursWarning: showOutsideHoursWarning
        )
    }

    private var saveButton: some View {
        AppButton(
            title: L10n.Onboarding.saveZone,
            icon: "checkmark.circle.fill",
            color: isFormValid ? AppColors.accentBlue : AppColors.buttonDisabled,
            foregroundColor: AppColors.onAccent,
            shadowColor: isFormValid ? nil : AppColors.buttonDisabledDepth,
            onTap: {
                guard isFormValid else { return }
                withAnimation(.snappy(duration: 0.25)) {
                    viewModel.updateZone(
                        id: zone.id,
                        name: zoneName.trimmingCharacters(in: .whitespacesAndNewlines),
                        colorRed: selectedColor.red,
                        colorGreen: selectedColor.green,
                        colorBlue: selectedColor.blue,
                        startTime: OnboardingViewModel.formatTime(startTime),
                        endTime: OnboardingViewModel.formatTime(endTime)
                    )
                }
                dismiss()
            }
        )
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1 : 0.55)
    }



    private func validateOverlap() {
        let start = OnboardingViewModel.formatTime(startTime)
        let end = OnboardingViewModel.formatTime(endTime)
        withAnimation(.snappy(duration: 0.2)) {
            showOverlapError = !startAfterEnd
                && viewModel.isTimeIntervalOverlapping(start: start, end: end, excludingID: zone.id)
            
            showOutsideHoursWarning = viewModel.isTimeIntervalOutsideActiveHours(start: startTime, end: endTime)
        }
    }
}
