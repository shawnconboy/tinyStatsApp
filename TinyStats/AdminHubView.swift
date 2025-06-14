import SwiftUI
import FirebaseFirestore

struct AdminHubView: View {
    var auth: AuthViewModel  // ✅ Accepts auth

    @State private var showChangeTeamSheet = false
    @State private var selectedTeamID: String = ""
    @State private var isUpdatingTeam = false

    var body: some View {
        VStack(spacing: 0) {
            // Only show for devs
            if let role = auth.adminProfile?.role, role == "developer" {
                Button(action: { showChangeTeamSheet = true }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Change Team")
                    }
                    .font(.headline)
                    .padding(8)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }

            AdminPanelView(auth: auth)  // ✅ Passes auth into AdminPanelView
        }
        .sheet(isPresented: $showChangeTeamSheet) {
            ChangeTeamSheet(
                auth: auth,
                isPresented: $showChangeTeamSheet,
                selectedTeamID: $selectedTeamID,
                isUpdatingTeam: $isUpdatingTeam
            )
        }
    }
}

// Sheet for changing team
private struct ChangeTeamSheet: View {
    @ObservedObject var auth: AuthViewModel
    @Binding var isPresented: Bool
    @Binding var selectedTeamID: String
    @Binding var isUpdatingTeam: Bool

    @State private var teams: [Team] = []

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Select Team")) {
                    Picker("Team", selection: $selectedTeamID) {
                        ForEach(teams, id: \.id) { team in
                            Text(team.name).tag(team.id)
                        }
                        Text("Clear Team").tag(Optional<String>(nil))
                    }
                }
                if isUpdatingTeam {
                    ProgressView("Updating...")
                }
                Button("Update Team") {
                    updateTeamID()
                }
                .disabled(selectedTeamID.isEmpty || isUpdatingTeam)
            }
            .navigationTitle("Change Team")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .onAppear {
                fetchTeams()
                if let current = auth.adminProfile?.teamID {
                    selectedTeamID = current
                }
            }
        }
    }

    private func fetchTeams() {
        let db = Firestore.firestore()
        guard let orgID = auth.adminProfile?.organizationID else { return }
        db.collection("teams").whereField("organizationID", isEqualTo: orgID).getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.teams = docs.map { doc in
                let data = doc.data()
                return Team(
                    _id: doc.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    ageGroup: data["ageGroup"] as? String ?? "",
                    organizationID: data["organizationID"] as? String ?? ""
                )
            }
        }
    }

    private func updateTeamID() {
        guard let adminID = auth.adminProfile?.id else { return }
        isUpdatingTeam = true
        let db = Firestore.firestore()
        // selectedTeamID is already the structured team ID (documentID)
        db.collection("admins").document(adminID).updateData([
            "teamID": selectedTeamID
        ]) { error in
            isUpdatingTeam = false
            if error == nil {
                // Refresh profile
                if let uid = auth.user?.uid {
                    auth.adminProfile = nil
                    auth.fetchUserProfile(for: uid)
                }
                isPresented = false
            }
        }
    }
}
