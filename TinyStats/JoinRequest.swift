import Foundation

struct JoinRequest: Identifiable {
    var id: String
    var parentName: String
    var childName: String
    var email: String
    var teamID: String
    var reason: String
    var uid: String

    init?(id: String, data: [String: Any]) {
        guard
            let parentName = data["parentName"] as? String,
            let childName = data["childName"] as? String,
            let email = data["email"] as? String,
            let teamID = data["teamID"] as? String,
            let reason = data["reason"] as? String,
            let uid = data["uid"] as? String
        else {
            return nil
        }

        self.id = id
        self.parentName = parentName
        self.childName = childName
        self.email = email
        self.teamID = teamID
        self.reason = reason
        self.uid = uid
    }
}
