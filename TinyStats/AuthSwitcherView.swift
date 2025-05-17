import SwiftUI

struct AuthSwitcherView: View {
    @Binding var isAuthenticated: Bool
    @State private var showSignIn = false

    var body: some View {
        VStack {
            if showSignIn {
                SignInView(isAuthenticated: $isAuthenticated)
            } else {
                SignUpRequestView(isAuthenticated: $isAuthenticated)
            }

            Button(action: {
                showSignIn.toggle()
            }) {
                Text(showSignIn ? "Need an account? Sign Up" : "Already have an account? Sign In")
                    .font(.footnote)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }
}
