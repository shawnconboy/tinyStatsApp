import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TeamTabView: View {
    @State private var isLoading = true
    @State private var isLoggedIn = false
    @State private var isApproved = false
    @State private var isAuthenticated = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Team Hub")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    if isLoading {
                        ProgressView("Loading...")
                    }

                    else if !isLoggedIn && !isAuthenticated {
                        AuthSwitcherView(isAuthenticated: $isAuthenticated)
                    }

                    else if isApproved || isAuthenticated {
                        TeamHubView()
                    }

                    else {
                        VStack(spacing: 16) {
                            Text("Your request has been submitted. Please wait for approval.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            Button("Refresh") {
                                checkUserState()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            checkUserState()
        }
    }

    func checkUserState() {
        guard let currentUser = Auth.auth().currentUser else {
            isLoggedIn = false
            isApproved = false
            isAuthenticated = false // ✅ Reset this too
            isLoading = false
            return
        }

        isLoggedIn = true

        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { doc, error in
            if let doc = doc, let data = doc.data() {
                if let status = data["status"] as? String, status == "approved" {
                    isApproved = true
                }
            }
            isLoading = false
        }
    }
}
