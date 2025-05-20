import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TeamView: View {
    @State private var isChecking = true
    @State private var isApproved = false
    @State private var teamID: String?
    @State private var goToAuth = false  // ✅ Track auth navigation

    var body: some View {
        NavigationStack {
            Group {
                if isChecking {
                    VStack {
                        Spacer()
                        ProgressView("Loading Team Info...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else if Auth.auth().currentUser == nil {
                    VStack(spacing: 16) {
                        Text("Sign in to view your team")
                            .font(.title2.bold())

                        Button {
                            goToAuth = true
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let teamID = teamID, isApproved {
                    TeamHubView(teamID: teamID)
                } else {
                    VStack(spacing: 16) {
                        Text("Join a Team")
                            .font(.title2.bold())
                        Text("Request access from your coach or organization to join your team's hub.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                if isChecking {
                    fetchTeamStatus()
                }
            }
            .navigationDestination(isPresented: $goToAuth) {
                AuthView()
            }
        }
    }

    private func fetchTeamStatus() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            isChecking = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.isApproved = data["isApproved"] as? Bool ?? false
                self.teamID = data["teamID"] as? String
                print("✅ Team data loaded: \(self.teamID ?? "none") approved: \(self.isApproved)")
            } else {
                print("❌ User document missing or malformed")
            }
            self.isChecking = false
        }
    }
}
