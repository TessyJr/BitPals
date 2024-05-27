import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isSignedIn: Bool

    var body: some View {
        VStack {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(_):
                    isSignedIn = true
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
            .signInWithAppleButtonStyle(
                colorScheme == .dark ? .white : .black
            )
            .frame(height: 64)
            .cornerRadius(8)
        }
    }
}
