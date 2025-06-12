import Foundation
import Firebase

class TeamHubViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var members: [Member] = []
    let team: Team

    init(team: Team) {
        self.team = team
        fetchMembers()
        fetchEvents()
    }

    func fetchMembers() {
        let db = Firestore.firestore()
        db.collection("members").whereField("teamID", isEqualTo: team.id).getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.members = docs.map { doc in
                let data = doc.data()
                let parentName = (data["name"] as? String) ?? (data["parentName"] as? String) ?? "Unknown"
                return Member(
                    _id: doc.documentID,
                    parentName: parentName,
                    childName: data["childName"] as? String ?? "",
                    jerseyNumber: data["jerseyNumber"] as? Int ?? 0,
                    teamID: data["teamID"] as? String ?? ""
                )
            }
        }
    }

    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("teams").document(team.id).collection("events").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.events = docs.map { doc in
                let data = doc.data()
                let eventDate: Date = (data["eventDate"] as? Timestamp)?.dateValue() ?? Date()
                return Event(
                    _id: doc.documentID,
                    teamAName: data["teamAName"] as? String ?? "",
                    teamBName: data["teamBName"] as? String ?? "",
                    snackVolunteerID: data["snackVolunteerID"] as? String,
                    snackVolunteerName: data["snackVolunteerName"] as? String,
                    eventDate: eventDate,
                    title: data["title"] as? String ?? "",
                    location: data["location"] as? String ?? "",
                    note: data["note"] as? String ?? ""
                )
            }
        }
    }

    func addEvent(teamAName: String, teamBName: String, snackVolunteerID: String?, snackVolunteerName: String?, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let newDoc = db.collection("teams").document(team.id).collection("events").document()
        let eventData: [String: Any] = [
            "teamAName": teamAName,
            "teamBName": teamBName,
            "snackVolunteerID": snackVolunteerID ?? "",
            "snackVolunteerName": snackVolunteerName ?? "",
            "eventDate": Timestamp(date: Date()),
            "title": "", // default empty
            "location": "", // default empty
            "note": "" // default empty
        ]
        newDoc.setData(eventData) { err in
            if err == nil { self.fetchEvents(); completion() }
        }
    }
}
