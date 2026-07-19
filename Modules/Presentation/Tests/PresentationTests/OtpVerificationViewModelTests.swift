import Domain
import XCTest
@testable import Presentation

@MainActor
final class OtpVerificationViewModelTests: XCTestCase {
    func testEnteringDigitsBuildsCodeAndMovesToNextField() {
        let viewModel = makeViewModel()

        XCTAssertEqual(viewModel.updateCodeDigit("1", at: 0), 1)
        XCTAssertEqual(viewModel.updateCodeDigit("2", at: 1), 2)
        XCTAssertEqual(viewModel.updateCodeDigit("3", at: 2), 3)

        XCTAssertEqual(viewModel.codeDigits, ["1", "2", "3", "", "", ""])
        XCTAssertEqual(viewModel.code, "123")
    }

    func testPastingCompleteCodeDistributesDigitsAndStartsVerification() async {
        let repository = AuthRepositoryStub()
        let viewModel = makeViewModel(repository: repository)

        XCTAssertNil(viewModel.updateCodeDigit("123456", at: 0))
        XCTAssertEqual(viewModel.codeDigits, ["1", "2", "3", "4", "5", "6"])

        await waitUntil { viewModel.state == .success }
        let lastVerifiedCode = await repository.lastVerifiedCode
        XCTAssertEqual(lastVerifiedCode, "123456")
    }

    func testDeletingDigitKeepsFocusOnEditedField() {
        let viewModel = makeViewModel()
        _ = viewModel.updateCodeDigit("7", at: 0)

        XCTAssertEqual(viewModel.updateCodeDigit("", at: 0), 0)
        XCTAssertEqual(viewModel.codeDigits[0], "")
        XCTAssertEqual(viewModel.code, "")
    }

    func testTypingIntoFilledFieldReplacesItsDigit() {
        let viewModel = makeViewModel()
        _ = viewModel.updateCodeDigit("7", at: 0)

        XCTAssertEqual(viewModel.updateCodeDigit("79", at: 0), 1)
        XCTAssertEqual(viewModel.codeDigits, ["9", "", "", "", "", ""])
    }

    private func makeViewModel(
        repository: AuthRepositoryStub = AuthRepositoryStub()
    ) -> OtpVerificationViewModel {
        OtpVerificationViewModel(
            email: "person@example.com",
            verifyOTPUseCase: VerifyOTPUseCase(repository: repository)
        )
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool
    ) async {
        for _ in 0..<100 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}

private actor AuthRepositoryStub: AuthRepository {
    private(set) var lastVerifiedCode: String?

    func requestOTP(email: String) async throws -> OTPRequestResult {
        OTPRequestResult(expiresInSeconds: 60, resendAvailableInSeconds: 30)
    }

    func verifyOTP(
        email: String,
        code: String,
        deviceId: String
    ) async throws -> VerifyOTPResult {
        lastVerifiedCode = code
        return VerifyOTPResult(
            user: UserEntity(id: "user-id", email: email, isNew: false)
        )
    }
}
