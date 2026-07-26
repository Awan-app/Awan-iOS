import Common
import Domain
import SwiftUI

struct AITaskResultSheet: View {
    let item: AITaskSheetItem
    let onAdd: (Int) -> Void
    let onDismiss: () -> Void

    @State private var editedDurationMinutes: Int

    init(
        item: AITaskSheetItem,
        onAdd: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.item = item
        self.onAdd = onAdd
        self.onDismiss = onDismiss
        _editedDurationMinutes = State(initialValue: max(15, item.task.estimatedDuration))
    }

    private var computedEndTime: Date {
        item.startTime.addingTimeInterval(Double(editedDurationMinutes) * 60)
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    var body: some View {
        VStack(spacing: 20) {
            // Header bar with title and close button
            HStack {
                Text(L10n.Home.aiTaskResultTitle)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            // Main Info Card using AppCard
            AppCard {
                VStack(alignment: .leading, spacing: 16) {
                    // Task Title & Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.task.title)
                            .font(AppFonts.title2Black)
                            .foregroundStyle(AppColors.textPrimary)

                        if let description = item.task.description, !description.isEmpty {
                            Text(description)
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Divider()

                    // Category / Zone
                    if let category = item.task.category {
                        HStack {
                            Text(L10n.Home.aiTaskCategory)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.textSecondary)
                            Spacer()
                            Text(category.name)
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.accentBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(AppColors.accentBlue.opacity(0.12), in: Capsule())
                        }
                    }

                    // Duration Editor (- / + buttons)
                    HStack {
                        Text(L10n.Home.duration)
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.textSecondary)

                        Spacer()

                        HStack(spacing: 12) {
                            Button {
                                if editedDurationMinutes > 15 {
                                    editedDurationMinutes -= 15
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(editedDurationMinutes > 15 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                            }
                            .disabled(editedDurationMinutes <= 15)

                            Text(L10n.Home.minutesShort(editedDurationMinutes))
                                .font(AppFonts.headlineBlack)
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(minWidth: 65)

                            Button {
                                if editedDurationMinutes < 480 {
                                    editedDurationMinutes += 15
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(editedDurationMinutes < 480 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                            }
                            .disabled(editedDurationMinutes >= 480)
                        }
                    }

                    Divider()

                    // Start & End Time Display
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Home.startTime)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textSecondary)
                            Text(Self.timeFormatter.string(from: item.startTime))
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.5))

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(L10n.Home.endTime)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textSecondary)
                            Text(Self.timeFormatter.string(from: computedEndTime))
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
            }

            // 3D Add Button using AppButton
            AppButton(
                title: L10n.Home.btnAddManualTask,
                icon: "plus.circle.fill",
                color: AppColors.accentBlue,
                size: .large,
                onTap: {
                    onAdd(editedDurationMinutes)
                }
            )
        }
        .padding(20)
        .background(AppColors.screenBackground.ignoresSafeArea())
    }
}



#Preview {
    AITaskResultSheet(item: .mock, onAdd: { _ in }, onDismiss: {})
}


