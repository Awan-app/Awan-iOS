import Combine
import Common
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class UserInfoViewModel {
    public var firstName = ""
    public var lastName = ""
    public var email = ""
    public var dateOfBirth = Calendar.current.date(
        from: DateComponents(year: 2000, month: 7, day: 21)
    ) ?? Date()
    public var profileImageData: Data?
    public var profileImageMimeType: String?
    public var profileImageFileName: String?
    public var profilePictureUrl: String?
    public var frameImageUrl: String?

    public var showToast = false
    public var toastMessage: String?
    public var toastIsSuccess = false
    public var isSaving = false

    @ObservationIgnored private var profileCancellable: AnyCancellable?
    @ObservationIgnored private var equippedItemsCancellable: AnyCancellable?

    private let getUserProfileUseCase: any GetUserProfileUseCase
    private let updateUserProfileUseCase: any UpdateUserProfileUseCase
    private let updateProfilePictureUseCase: any UpdateProfilePictureUseCase
    private let fetchEquippedItemsUseCase: (any FetchEquippedItemsUseCase)?

    public init(
        getUserProfileUseCase: any GetUserProfileUseCase,
        updateUserProfileUseCase: any UpdateUserProfileUseCase,
        updateProfilePictureUseCase: any UpdateProfilePictureUseCase,
        fetchEquippedItemsUseCase: (any FetchEquippedItemsUseCase)? = nil
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateUserProfileUseCase = updateUserProfileUseCase
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        self.fetchEquippedItemsUseCase = fetchEquippedItemsUseCase
    }

    public var isSaveDisabled: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func observeUserProfile() {
        profileCancellable?.cancel()
        profileCancellable = getUserProfileUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] profile in
                    self?.apply(profile)
                }
            )
        observeEquippedItems()
    }

    public func saveChanges() async {
        isSaving = true
        defer { isSaving = false }

        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            try await updateUserProfileUseCase.execute(
                firstName: firstName,
                lastName: lastName,
                birthDate: dateFormatter.string(from: dateOfBirth)
            )

            if let imageData = profileImageData,
               let mimeType = profileImageMimeType,
               let fileName = profileImageFileName {
                do {
                    try await updateProfilePictureUseCase.execute(
                        data: imageData,
                        fileName: fileName,
                        mimeType: mimeType
                    )
                } catch {
                    showToastMessage(error.localizedDescription, isSuccess: false)
                    return
                }
            }

            showToastMessage(L10n.UserInfo.changesSaved, isSuccess: true)
        } catch {
            showToastMessage(error.localizedDescription, isSuccess: false)
        }
    }

    public func refreshEquippedFrame() async {
        guard let fetchEquippedItemsUseCase else { return }

        do {
            _ = try await fetchEquippedItemsUseCase.execute()
        } catch is CancellationError {
            return
        } catch {
            // Personal information can still be edited if the frame request fails.
        }
    }

    private func apply(_ profile: UserProfile) {
        firstName = profile.firstName
        lastName = profile.lastName
        email = profile.email
        profilePictureUrl = profile.profilePictureUrl

        let components = DateComponents(
            year: profile.birthDate.year,
            month: profile.birthDate.month,
            day: profile.birthDate.day
        )
        dateOfBirth = Calendar.current.date(from: components) ?? dateOfBirth
    }

    private func observeEquippedItems() {
        guard let fetchEquippedItemsUseCase else { return }

        equippedItemsCancellable?.cancel()
        equippedItemsCancellable = fetchEquippedItemsUseCase.observeOrEmpty()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] equippedItems in
                    self?.frameImageUrl = equippedItems
                        .first { $0.type == .frame }?
                        .item.image
                }
            )
    }

    private func showToastMessage(_ message: String, isSuccess: Bool) {
        toastMessage = message
        toastIsSuccess = isSuccess
        showToast = true
    }
}
