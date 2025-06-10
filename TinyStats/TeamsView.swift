import SwiftUI
import Firebase

struct TeamsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var team: Team?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            if Auth.auth().currentUser == nil {
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
            } else if let team = team {
                TeamHubView(team: team)
            } else if isLoading {
                ProgressView("Loading your team...")
                    .navigationTitle("Team Hub")
            } else {
                Text("Failed to load team.")
                    .foregroundColor(.red)
            }
        }
        .onAppear(perform: loadTeam)
    }

    private func loadTeam() {
        guard let teamID = auth.adminProfile?.teamID ?? auth.memberProfile?.teamID else {
            self.isLoading = false
            return
        }

        Firestore.firestore().collection("teams").document(teamID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.team = Team(
                    _id: snapshot!.documentID,
                    name: data["name"] as? String ?? "",
                    ageGroup: data["ageGroup"] as? String ?? "",
                    organizationID: data["organizationID"] as? String ?? ""
                )
            }
            self.isLoading = false
        }
    }
}
