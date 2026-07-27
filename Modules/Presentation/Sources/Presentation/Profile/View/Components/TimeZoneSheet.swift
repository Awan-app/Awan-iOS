import Common
import Domain
import SwiftUI

struct TimeZoneSheet: View {
    let currentTimeZone: String
    let onSave: (String) -> Void
    let onDismiss: () -> Void

    @State private var selectedTimeZone: String
    @State private var searchText: String = ""

    private let allTimeZones: [String]

    init(
        currentTimeZone: String,
        onSave: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.currentTimeZone = currentTimeZone
        self.onSave = onSave
        self.onDismiss = onDismiss
        _selectedTimeZone = State(initialValue: currentTimeZone.isEmpty ? TimeZone.current.identifier : currentTimeZone)
        self.allTimeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
    }

    private var filteredTimeZones: [String] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return allTimeZones
        } else {
            return allTimeZones.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(L10n.Profile.timeZone)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.brandDarkBlue)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)

                TextField("Search Time Zone...", text: $searchText)
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textPrimary)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.outline.opacity(0.4), lineWidth: 1)
            )

            // Scrollable List Container using AppCard
            AppCard {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredTimeZones.enumerated()), id: \.element) { index, identifier in
                                Button(action: {
                                    selectedTimeZone = identifier
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(identifier)
                                                .font(AppFonts.subheadlineBold)
                                                .foregroundStyle(
                                                    selectedTimeZone == identifier
                                                        ? AppColors.accentBlue
                                                        : AppColors.textPrimary
                                                )

                                            Text(gmtOffsetString(for: identifier))
                                                .font(AppFonts.caption2Bold)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }

                                        Spacer()

                                        if selectedTimeZone == identifier {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(AppColors.accentBlue)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 8)
                                    .contentShape(Rectangle())
                                }
                                .id(identifier)

                                if index < filteredTimeZones.count - 1 {
                                    Rectangle()
                                        .fill(AppColors.divider)
                                        .frame(height: 1)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 280)
                    .onAppear {
                        if !selectedTimeZone.isEmpty {
                            proxy.scrollTo(selectedTimeZone, anchor: .center)
                        }
                    }
                }
            }

            Spacer()

            // 3D Save Button using AppButton
            AppButton(
                title: L10n.Common.save,
                icon: "checkmark.circle.fill",
                color: AppColors.accentBlue,
                size: .large,
                onTap: {
                    onSave(selectedTimeZone)
                }
            )
        }
        .padding(20)
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private func gmtOffsetString(for identifier: String) -> String {
        guard let tz = TimeZone(identifier: identifier) else { return "" }
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs((seconds % 3600) / 60)
        if hours >= 0 {
            return String(format: "GMT+%d:%02d", hours, minutes)
        } else {
            return String(format: "GMT%d:%02d", hours, minutes)
        }
    }
}

#if DEBUG
#Preview {
    TimeZoneSheet(
        currentTimeZone: "America/New_York",
        onSave: { _ in },
        onDismiss: {}
    )
}
#endif
