import Foundation
import FirebaseFirestore

class TeamDetailViewModel: ObservableObject {
    @Published var coaches: [User] = []
    @Published var members: [User] = []

    func fetchCoaches(for team: Team) {
        let db = Firestore.firestore()
        guard let coachIDs = team.coachIDs, !coachIDs.isEmpty else {
            self.coaches = []
            return
        }
        db.collection("users")
            .whereField("role", isEqualTo: "coach")
            .whereField("uid", in: coachIDs)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.coaches = docs.compactMap { try? $0.data(as: User.self) }
                } else {
                    self.coaches = []
                }
            }
    }

    func fetchMembers(for team: Team) {
        let db = Firestore.firestore()
        guard let memberIDs = team.memberIDs, !memberIDs.isEmpty else {
            self.members = []
            return
        }
        db.collection("users")
            .whereField("uid", in: memberIDs)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.members = docs.compactMap { try? $0.data(as: User.self) }
                } else {
                    self.members = []
                }
            }
    }
}
