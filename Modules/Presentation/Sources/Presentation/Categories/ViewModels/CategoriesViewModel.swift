import Combine
import Common
import Domain
import Foundation
import Observation

public enum CategoriesLoadState: Equatable, Sendable {
    case idle
    case loading
    case content
    case failure
}

@MainActor
@Observable
public final class CategoriesViewModel {
    public private(set) var loadState: CategoriesLoadState = .idle
    public private(set) var categories: [TaskCategory] = []
    public private(set) var isCreating = false
    public private(set) var isUpdating = false
    public private(set) var isDeleting = false
    public var errorMessage: String?
    
    public var isCreateSheetPresented = false
    public var editingCategory: TaskCategory?
    public var deletingCategory: TaskCategory?
    public var showDeleteAlert = false

    private let fetchCategoriesUseCase: any FetchCategoriesUseCase
    private let createCategoryUseCase: any CreateCategoryUseCase
    private let updateCategoryUseCase: any UpdateCategoryUseCase
    private let deleteCategoryUseCase: any DeleteCategoryUseCase

    private var cancellable: AnyCancellable?

    public init(
        fetchCategoriesUseCase: any FetchCategoriesUseCase,
        createCategoryUseCase: any CreateCategoryUseCase,
        updateCategoryUseCase: any UpdateCategoryUseCase,
        deleteCategoryUseCase: any DeleteCategoryUseCase
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }

    public func load() {
        guard loadState != .loading else { return }
        if categories.isEmpty {
            loadState = .loading
        }

        cancellable?.cancel()
        cancellable = fetchCategoriesUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure = completion, self.categories.isEmpty {
                        self.loadState = .failure
                    }
                },
                receiveValue: { [weak self] items in
                    guard let self else { return }
                    self.categories = items
                    self.loadState = .content
                }
            )
    }

    public func createCategory(name: String) async -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        isCreating = true
        errorMessage = nil
        defer { isCreating = false }

        do {
            let created = try await createCategoryUseCase.execute(name: trimmed)
            if !categories.contains(where: { $0.id == created.id }) {
                categories.append(created)
                categories.sort {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            isCreateSheetPresented = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func updateCategory(id: UUID, name: String) async -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        isUpdating = true
        errorMessage = nil
        defer { isUpdating = false }

        do {
            let updated = try await updateCategoryUseCase.execute(id: id, name: trimmed)
            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index] = updated
                categories.sort {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            editingCategory = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func deleteCategory(id: UUID) async -> Bool {
        isDeleting = true
        errorMessage = nil
        defer {
            isDeleting = false
            deletingCategory = nil
            showDeleteAlert = false
        }

        do {
            try await deleteCategoryUseCase.execute(id: id)
            categories.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func promptDelete(category: TaskCategory) {
        deletingCategory = category
        showDeleteAlert = true
    }
}
