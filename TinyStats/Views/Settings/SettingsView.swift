import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @State private var role: String = ""
    @State private var orgID: String = ""
    @State private var isLoading = true
    @State private var showAdminPanel = false
    @State private var isLoggedIn = Auth.auth().currentUser != nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Account Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        if isLoggedIn {
                            Button(action: signOut) {
                                HStack {
                                    Image(systemName: "arrow.backward.circle")
                                    Text("Sign Out")
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        } else {
                            Text("Not signed in")
                                .foregroundColor(.secondary)
                        }
                    }

                    // Admin Tools Section
                    if isLoggedIn && (role == "developer" || role == "admin") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Admin Tools")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Button(action: { showAdminPanel = true }) {
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("Manage Admins")
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color.white.edgesIgnoringSafeArea(.all)) // ✅ white background
            .navigationTitle("Settings")
            .onAppear {
                loadUserRole()
                isLoggedIn = Auth.auth().currentUser != nil
            }
            .sheet(isPresented: $showAdminPanel) {
                AdminManagementView()
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            role = ""
            orgID = ""
            print("✅ Signed out successfully")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
    }

    func loadUserRole() {
        guard let currentUser = Auth.auth().currentUser else {
            role = ""
            orgID = ""
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { doc, error in
            if let doc = doc, let data = doc.data() {
                role = data["role"] as? String ?? ""
                orgID = data["orgID"] as? String ?? ""
            }
        }
    }
}
