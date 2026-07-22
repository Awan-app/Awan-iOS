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

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                infoTag
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

    private var zonesList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.suggestedZones) { zone in
                ZoneCard(zone: zone) {
                    withAnimation(.snappy(duration: 0.25)) {
                        viewModel.removeZone(zone)
                    }
                }
                .onDrag {
                    self.draggedZone = zone
                    return NSItemProvider(object: zone.id.uuidString as NSString)
                }
                .onDrop(
                    of: [.text],
                    delegate: ZoneDropDelegate(
                        item: zone,
                        items: viewModel.suggestedZones,
                        draggedItem: $draggedZone,
                        swapAction: { sourceIndex, destinationIndex in
                            withAnimation(.snappy(duration: 0.25)) {
                                viewModel.swapZones(at: sourceIndex, with: destinationIndex)
                            }
                        }
                    )
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

// MARK: - Drop Delegate

struct ZoneDropDelegate: DropDelegate {
    let item: SuggestedZone
    let items: [SuggestedZone]
    @Binding var draggedItem: SuggestedZone?
    let swapAction: (Int, Int) -> Void

    func dropEntered(info: DropInfo) {
        // Do not update the array during the drag to prevent glitches
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = draggedItem, draggedItem != item else { 
            self.draggedItem = nil
            return false 
        }
        guard let from = items.firstIndex(of: draggedItem),
              let to = items.firstIndex(of: item) else { 
            self.draggedItem = nil
            return false 
        }
        
        swapAction(from, to)
        self.draggedItem = nil
        return true
    }
}

#Preview {
    OnboardingSuggestedZonesView(viewModel: .preview, onContinue: {})
}

