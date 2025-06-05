import Foundation

struct Admin: Identifiable {
    var id: String { _id }
    let _id: String
    let name: String
    let uid: String
    let email: String?
    let role: String?
}

struct Member: Identifiable {
    var id: String { _id }
    let _id: String
    let parentName: String
    let childName: String
    let jerseyNumber: Int
    let teamID: String
}

struct Team: Identifiable {
    var id: String { _id }
    let _id: String
    let name: String
    let ageGroup: String
    let organizationID: String
}
