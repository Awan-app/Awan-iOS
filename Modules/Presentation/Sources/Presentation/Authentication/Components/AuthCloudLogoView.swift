import SwiftUI

struct AuthCloudLogoView: View {
    var body: some View {
        Image("login-logo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .phaseAnimator([false, true]) { content, phase in
                content.offset(y: phase ? -2 : 2)
            } animation: { _ in
                .easeInOut(duration: 3)
            }
    }
}
