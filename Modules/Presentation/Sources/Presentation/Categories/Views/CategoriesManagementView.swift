import Common
import Domain
import SwiftUI

public struct CategoriesManagementView: View {
    @State private var viewModel: CategoriesViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: CategoriesViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CategoriesScreenHeader(
                    onBack: { dismiss() }
                )

                switch viewModel.loadState {
                case .idle, .loading:
                    ProgressView()
                        .tint(AppColors.accentBlue)
                        .accessibilityLabel(L10n.Profile.loading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failure:
                    CategoryLoadFailureView(onRetry: { viewModel.load() })
                        .padding(24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .content:
                    if viewModel.categories.isEmpty {
                        CategoryEmptyStateView(
                            onAddTap: { viewModel.isCreateSheetPresented = true }
                        )
                        .padding(24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        contentList
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.isCreateSheetPresented) {
            CategoryAddSheet(
                onSave: { name in
                    _ = await viewModel.createCategory(name: name)
                },
                onDismiss: {
                    viewModel.isCreateSheetPresented = false
                }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.editingCategory) { category in
            CategoryEditSheet(
                category: category,
                onSave: { name in
                    _ = await viewModel.updateCategory(id: category.id, name: name)
                },
                onDismiss: {
                    viewModel.editingCategory = nil
                }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
        .alert(
            L10n.Categories.delete,
            isPresented: $viewModel.showDeleteAlert,
            presenting: viewModel.deletingCategory
        ) { category in
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.deletingCategory = nil
            }
            Button(L10n.Categories.delete, role: .destructive) {
                Task {
                    _ = await viewModel.deleteCategory(id: category.id)
                }
            }
        } message: { _ in
            Text(L10n.Categories.deleteConfirm)
        }
        .task {
            viewModel.load()
        }
    }

    private var contentList: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        CategoryManagementRow(
                            category: category,
                            onEdit: {
                                viewModel.editingCategory = category
                            },
                            onDelete: {
                                viewModel.promptDelete(category: category)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }

            AppButton(
                title: L10n.Categories.create,
                icon: "plus.circle.fill",
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                onTap: {
                    viewModel.isCreateSheetPresented = true
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}

#Preview {
    NavigationStack {
        CategoriesManagementView(
            viewModel: CategoriesViewModel(
                fetchCategoriesUseCase: MockFetchCategoriesUseCase(),
                createCategoryUseCase: MockCreateCategoryUseCase(),
                updateCategoryUseCase: MockUpdateCategoryUseCase(),
                deleteCategoryUseCase: MockDeleteCategoryUseCase()
            )
        )
    }
}
