import SwiftUI
import FirebaseFirestore

struct OrgTeamsView: View {
    let orgID: String
    let onAdd: () -> Void
    @State private var teams: [Team] = []
    @State private var selectedTeam: Team? = nil
    @State private var showEditModal = false
    @State private var showDetailSheet = false
    @State private var showDeleteAlert = false
    @State private var teamToDelete: Team? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Teams")
                    .font(.subheadline.bold())
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                }
            }

            if teams.isEmpty {
                Text("No teams yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(teams) { team in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(team.name)
                                .font(.body.weight(.semibold))
                            Text("Age Group: \(team.ageGroup)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Players: \(team.playerCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6).opacity(0.7))
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedTeam = team
                        showDetailSheet = true
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            teamToDelete = team
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            selectedTeam = team
                            showEditModal = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchTeams)
        .sheet(isPresented: $showDetailSheet, onDismiss: { selectedTeam = nil }) {
            if let team = selectedTeam {
                TeamDetailSheet(team: team)
            }
        }
        .sheet(isPresented: $showEditModal, onDismiss: { selectedTeam = nil }) {
            if let team = selectedTeam {
                 EditTeamFormView(team: team) {
                    showEditModal = false
                    fetchTeams()
                }
            }
        }
        .alert("Delete Team?", isPresented: $showDeleteAlert, presenting: teamToDelete) { team in
            Button("Delete", role: .destructive) {
                deleteTeam(team)
            }
            Button("Cancel", role: .cancel) {}
        } message: { team in
            Text("Are you sure you want to remove \(team.name)?")
        }
    
    }


    func fetchTeams() {
        let db = Firestore.firestore()
        db.collection("teams")
            .whereField("orgID", isEqualTo: orgID)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    let fetched = docs.map { doc in
                        Team(
                            id: doc.documentID,
                            name: doc["name"] as? String ?? "Unnamed Team",
                            ageGroup: doc["ageGroup"] as? String ?? "",
                            playerCount: doc["playerCount"] as? Int ?? 0,
                            orgID: doc["orgID"] as? String ?? ""
                        )
                    }
                    DispatchQueue.main.async {
                        self.teams = fetched.sorted { $0.name < $1.name }
                    }
                }
            }
    }

    private func deleteTeam(_ team: Team) {
        let db = Firestore.firestore()
        db.collection("teams").document(team.id).delete { error in
            if error == nil {
                fetchTeams()
            }
            // Optionally handle error
        }
    }
}
