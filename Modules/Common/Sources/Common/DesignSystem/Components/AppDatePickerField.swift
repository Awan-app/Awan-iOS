import SwiftUI

public struct AppCalendarPickerButton<Label: View>: View {
    @Binding private var selection: Date

    private let title: String
    private let range: ClosedRange<Date>
    private let label: Label

    @State private var isPickerPresented = false
    @State private var draftSelection: Date

    public init(
        selection: Binding<Date>,
        title: String,
        in range: ClosedRange<Date>,
        @ViewBuilder label: () -> Label
    ) {
        _selection = selection
        _draftSelection = State(initialValue: selection.wrappedValue)
        self.title = title
        self.range = range
        self.label = label()
    }

    public var body: some View {
        Button {
            draftSelection = selection
            isPickerPresented = true
        } label: {
            label
        }
#if os(iOS)
        .fullScreenCover(isPresented: $isPickerPresented) {
            calendarPopup
        }
#endif
        .accessibilityLabel(title)
        .accessibilityValue(
            selection.formatted(.dateTime.day().month(.wide).year())
        )
    }

    private var calendarPopup: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
                .onTapGesture { isPickerPresented = false }

            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 24),
                surfaceColor: AppColors.sheetBackground,
                borderColor: AppColors.accentBlue.opacity(0.30),
                depthColor: AppColors.accentBlueDepth.opacity(0.55),
                depthOffset: 7,
                contentInsets: EdgeInsets(top: 20, leading: 18, bottom: 22, trailing: 18)
            ) {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.accentBlue)

                        Text(title)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        Button {
                            isPickerPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(AppFonts.captionIconBlack)
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(width: 36, height: 36)
                                .contentShape(Circle())
                        }
                        .buttonStyle(
                            AppDepthButtonStyle(
                                shape: .circle,
                                surfaceColor: AppColors.surface,
                                borderColor: AppColors.outline.opacity(0.12),
                                depthColor: AppColors.outline.opacity(0.18),
                                depthOffset: 3
                            )
                        )
                        .accessibilityLabel(L10n.Common.cancel)
                    }

                    DatePicker(
                        title,
                        selection: $draftSelection,
                        in: range,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(AppColors.accentBlue)
                    .frame(maxWidth: .infinity)

                    AppButton(
                        title: L10n.Common.save,
                        icon: "checkmark.circle.fill",
                        color: AppColors.accentBlue,
                        foregroundColor: AppColors.onAccent
                    ) {
                        selection = draftSelection
                        isPickerPresented = false
                    }
                }
            }
            .frame(maxWidth: 390)
            .padding(.horizontal, 20)
        }
        .presentationBackground(.clear)
    }
}

public struct AppDatePickerField: View {
    @Binding private var selection: Date

    private let title: String
    private let range: ClosedRange<Date>

    public init(
        selection: Binding<Date>,
        title: String,
        in range: ClosedRange<Date>
    ) {
        _selection = selection
        self.title = title
        self.range = range
    }

    public var body: some View {
        AppCalendarPickerButton(
            selection: $selection,
            title: title,
            in: range
        ) {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(AppFonts.bodyBold)
                    .foregroundStyle(AppColors.accentBlue)

                Text(selection, format: .dateTime.day().month(.wide).year())
                    .font(AppFonts.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Image(systemName: "chevron.up.chevron.down")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .roundedRectangle(cornerRadius: 16),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.accentBlue.opacity(0.28),
                depthColor: AppColors.accentBlueDepth.opacity(0.55),
                depthOffset: 5
            )
        )
    }
}

#Preview("Light") {
    @Previewable @State var date = Date()

    AppDatePickerField(
        selection: $date,
        title: "Override date",
        in: Date()...Date.distantFuture
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    @Previewable @State var date = Date()

    AppDatePickerField(
        selection: $date,
        title: "Override date",
        in: Date()...Date.distantFuture
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
