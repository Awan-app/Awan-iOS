import SwiftUI

struct AuthCloudLogoView: View {
    @State private var animateMascot = false

    var body: some View {
        Image("login-logo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .offset(y: animateMascot ? 0 : -30)
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 150, damping: 6).delay(0.2)) {
                    animateMascot = true
                }
            }
    }
}
