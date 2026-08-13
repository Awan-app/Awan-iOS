//
//  CreateGoalSheet.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct CreateGoalSheet: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var hasDeadline: Bool = false
    @State private var targetDate: Date = Date().addingTimeInterval(86400 * 7)

    let isSubmitting: Bool
    let onCreateGoal: (String, String?, Date?) -> Void
    let onDismiss: () -> Void

    private var isSubmitDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 24) {
                    headerView

                    VStack(spacing: 12) {
                        // Title field
                        fieldSection(label: "Title") {
                            AppTextField(
                                text: $title,
                                placeholder: L10n.Goals.createTitlePlaceholder
                            )
                        }

                        // Description field
                        fieldSection(label: "Description") {
                            AppTextField(
                                text: $description,
                                placeholder: L10n.Goals.createDescriptionPlaceholder,
                                axis: .vertical,
                                lineLimit: 1...4
                            )
                        }

                        // Deadline date picker field
                        deadlinePicker
                    }
                    .padding(.horizontal, 16)

                    // Submit button
                    AppButton(
                        title: L10n.Goals.createButton,
                        icon: "target",
                        color: isSubmitDisabled ? AppColors.skyGradientTop.opacity(0.4) : AppColors.accentBlue,
                        foregroundColor: isSubmitDisabled ? AppColors.brandDarkBlue.opacity(0.5) : AppColors.onAccent,
                        shadowColor: isSubmitDisabled ? .clear : nil,
                        isLoading: isSubmitting,
                        onTap: submit
                    )
                    .disabled(isSubmitDisabled)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(AppColors.screenBackground)
        .presentationDetents([.height(510), .large])
        .presentationCornerRadius(28)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(false)
    }

    private var headerView: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(AppColors.accentBlue.opacity(0.12))
                .overlay(
                    Image(systemName: "target")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                )
                .frame(width: 56, height: 56)
                .padding(.top, 8)

            Text(L10n.Goals.createTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.Goals.createSubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)

            content()
        }
    }

    private var deadlinePicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Goal deadline")
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)

            if hasDeadline {
                AppDatePickerField(
                    selection: $targetDate,
                    title: "Goal deadline",
                    in: Date()...Date.distantFuture
                )
                .transition(.opacity.combined(with: .move(edge: .top)))

                Button {
                    withAnimation(.snappy) { hasDeadline = false }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 11, weight: .bold))
                        Text("Remove deadline")
                            .font(AppFonts.captionHeavy)
                    }
                    .foregroundStyle(AppColors.destructive)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppColors.destructive.opacity(0.10))
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            } else {
                Button {
                    withAnimation(.snappy) { hasDeadline = true }
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(AppColors.accentBlue.opacity(0.12))
                                .frame(width: 32, height: 32)
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.accentBlue)
                        }

                        Text("Add deadline")
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(AppColors.accentBlue)

                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func submit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let trimmedDesc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let descParam = trimmedDesc.isEmpty ? nil : trimmedDesc
        let dateParam = hasDeadline ? targetDate : nil

        onCreateGoal(trimmedTitle, descParam, dateParam)
    }
}
