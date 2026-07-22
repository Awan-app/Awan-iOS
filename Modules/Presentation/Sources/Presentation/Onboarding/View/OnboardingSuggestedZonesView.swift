//
//  OnboardingSuggestedZonesView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

struct OnboardingSuggestedZonesView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @State private var draggedZone: SuggestedZone?
    @State private var dragOffset: CGSize = .zero
    @State private var cumulativeOffset: CGFloat = 0
    @State private var editingZone: SuggestedZone?
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                infoTag
                if viewModel.hasZoneOutsideActiveHours {
                    outOfBoundsWarning
                }
                if viewModel.availableHours < 10 {
                    shortDayWarning
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                zonesList
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }

            Spacer(minLength: 0)

            bottomButtons
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .sheet(isPresented: $viewModel.isAddZoneSheetPresented) {
            AddZoneSheet(viewModel: viewModel)
        }
        .sheet(item: $editingZone) { zone in
            EditZoneTimeSheet(viewModel: viewModel, zone: zone)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Text(L10n.Onboarding.zonesTitle)
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.brandDarkBlue)
    }

    private var infoTag: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 12, weight: .bold))
            Text(L10n.Onboarding.changeAnytime)
                .font(AppFonts.caption2Bold)
        }
        .foregroundStyle(AppColors.accentBlue)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            AppColors.accentBlue.opacity(0.1),
            in: Capsule()
        )
    }

    private var outOfBoundsWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
            Text("Some zones fall outside your active wake/sleep times.")
                .font(AppFonts.caption2Bold)
        }
        .foregroundStyle(AppColors.warning)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppColors.warning.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var shortDayWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
            Text("Your day is short (less than 10 hours).")
                .font(AppFonts.caption2Bold)
        }
        .foregroundStyle(AppColors.warning)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppColors.warning.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var zonesList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.suggestedZones) { zone in
                ZoneCard(zone: zone) {
                    withAnimation(.snappy(duration: 0.25)) {
                        viewModel.removeZone(zone)
                    }
                }
                .onTapGesture {
                    editingZone = zone
                }
                .offset(y: draggedZone == zone ? dragOffset.height : 0)
                .zIndex(draggedZone == zone ? 1 : 0)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            if draggedZone == nil {
                                draggedZone = zone
                                cumulativeOffset = 0
                            }
                            
                            dragOffset = CGSize(width: 0, height: value.translation.height - cumulativeOffset)
                            
                            if let currentIndex = viewModel.suggestedZones.firstIndex(of: zone) {
                                let itemHeight: CGFloat = 74
                                
                                if dragOffset.height > itemHeight && currentIndex < viewModel.suggestedZones.count - 1 {
                                    cumulativeOffset += itemHeight
                                    dragOffset.height -= itemHeight
                                    withAnimation(.snappy(duration: 0.25)) {
                                        viewModel.swapZones(at: currentIndex, with: currentIndex + 1)
                                    }
                                } else if dragOffset.height < -itemHeight && currentIndex > 0 {
                                    cumulativeOffset -= itemHeight
                                    dragOffset.height += itemHeight
                                    withAnimation(.snappy(duration: 0.25)) {
                                        viewModel.swapZones(at: currentIndex, with: currentIndex - 1)
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.snappy(duration: 0.25)) {
                                draggedZone = nil
                                dragOffset = .zero
                                cumulativeOffset = 0
                            }
                        }
                )
            }

            AddZoneButton(onTap: {
                viewModel.isAddZoneSheetPresented = true
            })
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            AppButton(
                title: L10n.Onboarding.setManually,
                icon: nil,
                color: AppColors.surface,
                foregroundColor: AppColors.brandDarkBlue,
                borderColor: AppColors.accentBlue,
                shadowColor: .clear,
                useGradient: false,
                onTap: {
                    onContinue()
                }
            )

            AppButton(
                title: L10n.Onboarding.useThis,
                icon: nil,
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                onTap: {
                    onContinue()
                }
            )
        }
    }
}


#Preview {
    OnboardingSuggestedZonesView(viewModel: .preview, onContinue: {})
}

