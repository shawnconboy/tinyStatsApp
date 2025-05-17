import SwiftUI
import FirebaseFirestore

struct OrgTeamsView: View {
    let orgID: String
    let onAdd: () -> Void
    @State private var teams: [Team] = []

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
                        Text("• \(team.name) – \(team.playerCount) players")
                        Spacer()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            // TODO: Delete team
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            // TODO: Edit team
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchTeams)
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
                            playerCount: doc["playerCount"] as? Int ?? 0
                        )
                    }
                    DispatchQueue.main.async {
                        self.teams = fetched.sorted { $0.name < $1.name }
                    }
                }
            }
    }
}
