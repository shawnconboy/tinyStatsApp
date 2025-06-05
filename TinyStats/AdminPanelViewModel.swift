import Foundation
import Firebase

class AdminPanelViewModel: ObservableObject {
    @Published var teams: [Team] = []
    private var auth: AuthViewModel

    init(auth: AuthViewModel) {
        self.auth = auth
        fetchTeams()
    }

    func fetchTeams() {
        guard let currentOrgID = auth.adminProfile?.organizationID else { return }
        let db = Firestore.firestore()

        db.collection("teams").whereField("organizationID", isEqualTo: currentOrgID).getDocuments { snapshot, _ in
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
}
