import SwiftUI
import Firebase

struct TeamsView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            if Auth.auth().currentUser == nil {
                // 🔓 Not logged in
                VStack(spacing: 16) {
                    Text("Access Your Team")
                        .font(.title.bold())

                    NavigationLink("Login to Your Account", destination: TeamLoginView())
                        .buttonStyle(.borderedProminent)

                    NavigationLink("Sign Up to Join a Team", destination: JoinTeamSignUpView())
                        .buttonStyle(.bordered)
                }
                .padding()
                .navigationTitle("Team Hub")
            } else {
                // ✅ Logged in – show Team Hub directly
                TeamHubView()
            }
        }
    }
}
