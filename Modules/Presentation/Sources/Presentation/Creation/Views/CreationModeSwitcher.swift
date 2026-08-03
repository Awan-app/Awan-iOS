import Common
import SwiftUI

enum CreationMode: String, CaseIterable, Identifiable {
    case task
    case goal

    var id: Self { self }
}

struct CreationModeSwitcher: View {
    @Binding var selectedMode: CreationMode

    var body: some View {
        AppSegmentedPicker(
            selection: $selectedMode,
            items: [
                .init(
                    value: .task,
                    title: L10n.Home.addTask,
                    icon: "checkmark.circle.fill"
                ),
                .init(
                    value: .goal,
                    title: L10n.Home.addGoal,
                    icon: "target"
                )
            ]
        )
    }
}


#Preview {
    CreationModeSwitcher(selectedMode: .constant(.task))
        .padding()
}
