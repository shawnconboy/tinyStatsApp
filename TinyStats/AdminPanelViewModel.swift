import Foundation
import Firebase

class AdminPanelViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var pendingRequests: [JoinRequest] = []

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

    func fetchPendingJoinRequests(for teamID: String) {
        let db = Firestore.firestore()
        db.collection("joinRequests")
            .whereField("teamID", isEqualTo: teamID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    self.pendingRequests = snapshot.documents.compactMap { doc in
                        let data = doc.data()
                        return JoinRequest(
                            id: doc.documentID,
                            parentName: data["parentName"] as? String ?? "",
                            childName: data["childName"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            teamID: data["teamID"] as? String ?? "",
                            status: data["status"] as? String ?? "",
                            uid: data["uid"] as? String ?? ""
                        )
                    }
                }
            }
    }

    func approveRequest(_ request: JoinRequest) {
        let db = Firestore.firestore()
        let memberData: [String: Any] = [
            "parentName": request.parentName,
            "childName": request.childName,
            "email": request.email,
            "teamID": request.teamID,
            "uid": request.uid,
            "approved": true
        ]
        db.collection("members").document(request.uid).setData(memberData) { error in
            if error == nil {
                db.collection("joinRequests").document(request.id).delete()
            }
        }
    }

    func denyRequest(_ request: JoinRequest) {
        let db = Firestore.firestore()
        db.collection("joinRequests").document(request.id).delete()
    }
}
