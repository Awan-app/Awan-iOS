import UIKit
import GoogleSignIn

@MainActor
public enum GoogleSignInHelper {
    public struct SignInTokens: Sendable {
        public let idToken: String
        public let accessToken: String
    }

    public static func signIn() async throws -> SignInTokens {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
                ?? windowScene.windows.first?.rootViewController else {
            throw NSError(
                domain: "GoogleSignInHelper",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Cannot find root view controller"]
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let idToken = signInResult?.user.idToken?.tokenString else {
                    continuation.resume(throwing: NSError(
                        domain: "GoogleSignInHelper",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Missing ID token from Google Sign-In"]
                    ))
                    return
                }

                let accessToken = signInResult?.user.accessToken.tokenString ?? ""
                continuation.resume(returning: SignInTokens(idToken: idToken, accessToken: accessToken))
            }
        }
    }

    public static func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}
