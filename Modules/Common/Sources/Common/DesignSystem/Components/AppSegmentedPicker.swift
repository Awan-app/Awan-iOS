import SwiftUI

public struct AppSegmentedPickerItem<Selection: Hashable>: Identifiable {
    public let value: Selection
    public let title: String
    public let icon: String?

    public var id: Selection { value }

    public init(value: Selection, title: String, icon: String? = nil) {
        self.value = value
        self.title = title
        self.icon = icon
    }
}

public struct AppSegmentedPicker<Selection: Hashable>: View {
    @Binding private var selection: Selection

    private let items: [AppSegmentedPickerItem<Selection>]

    public init(
        selection: Binding<Selection>,
        items: [AppSegmentedPickerItem<Selection>]
    ) {
        _selection = selection
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(items) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                        selection = item.value
                    }
                } label: {
                    if let icon = item.icon {
                        Label(item.title, systemImage: icon)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(item.title)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(
                    AppSegmentedPickerButtonStyle(isSelected: selection == item.value)
                )
                .accessibilityAddTraits(selection == item.value ? .isSelected : [])
            }
        }
        .padding(5)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(AppColors.accentBlueDepth.opacity(0.22))
                    .offset(y: 4)

                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(AppColors.surface)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.22), lineWidth: 1.5)
        }
        .padding(.bottom, 4)
        .accessibilityElement(children: .contain)
    }
}

private struct AppSegmentedPickerButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.subheadlineHeavy)
            .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.brandDarkBlue)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColors.accentBlueDepth)
                            .offset(y: configuration.isPressed ? 1 : 4)
                    }

                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(AppColors.accentBlue.gradient)
                                : AnyShapeStyle(AppColors.surface)
                        )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected
                            ? AppColors.onAccent.opacity(0.24)
                            : AppColors.accentBlue.opacity(0.16),
                        lineWidth: 1.5
                    )
            }
            .offset(y: isSelected && configuration.isPressed ? 3 : 0)
            .padding(.bottom, 4)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
            .animation(.snappy(duration: 0.18), value: isSelected)
    }
}

private enum PreviewSelection: Hashable {
    case first
    case second
}

#Preview("Light") {
    @Previewable @State var selection = PreviewSelection.first

    AppSegmentedPicker(
        selection: $selection,
        items: [
            .init(value: .first, title: "Task", icon: "checkmark.circle.fill"),
            .init(value: .second, title: "Goal", icon: "target")
        ]
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    @Previewable @State var selection = PreviewSelection.second

    AppSegmentedPicker(
        selection: $selection,
        items: [
            .init(value: .first, title: "Weekly routine"),
            .init(value: .second, title: "Date override")
        ]
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
