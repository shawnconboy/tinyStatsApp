import Foundation
import Firebase

class TeamDetailViewModel: ObservableObject {
    @Published var members: [Member] = []

    init(teamID: String) {
        fetchMembers(for: teamID)
    }

    func fetchMembers(for teamID: String) {
        let db = Firestore.firestore()

        db.collection("members").whereField("teamID", isEqualTo: teamID).getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.members = docs.map { doc in
                let data = doc.data()
                return Member(
                    _id: doc.documentID,
                    parentName: data["parentName"] as? String ?? "Unknown",
                    childName: data["childName"] as? String ?? "",
                    jerseyNumber: data["jerseyNumber"] as? Int ?? 0,
                    teamID: data["teamID"] as? String ?? ""
                )
            }
        }
    }
}
