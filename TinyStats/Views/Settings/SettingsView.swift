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
            Form {
                Section(header: Text("Account")) {
                    if isLoggedIn {
                        Button("Sign Out") {
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
                    } else {
                        Text("Not signed in")
                            .foregroundColor(.secondary)
                    }
                }

                if isLoggedIn && (role == "developer" || role == "admin") {
                    Section(header: Text("Admin Tools")) {
                        Button("Manage Admins") {
                            showAdminPanel = true
                        }
                    }
                }
            }
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
 
