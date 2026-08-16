import Common
import SwiftUI

struct CategoryCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyZonesViewModel

    var body: some View {
        CategoryAddSheet(
            onSave: { name in
                await viewModel.createCategory(name: name)
                if viewModel.state.categoryErrorMessage == nil {
                    dismiss()
                }
            },
            onDismiss: {
                dismiss()
            }
        )
    }
}
