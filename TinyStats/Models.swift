import Foundation

struct Admin: Identifiable, Equatable {
    var id: String { _id }
    let _id: String
    let name: String
    let uid: String
    let email: String?
    let role: String?

    static func == (lhs: Admin, rhs: Admin) -> Bool {
        lhs._id == rhs._id
    }
}

struct Member: Identifiable, Equatable {
    var id: String { _id }
    let _id: String
    let parentName: String
    let childName: String
    let jerseyNumber: Int
    let teamID: String

    static func == (lhs: Member, rhs: Member) -> Bool {
        lhs._id == rhs._id
    }
}

struct Team: Identifiable, Equatable, Hashable {
    var id: String { _id }
    let _id: String
    let name: String
    let ageGroup: String
    let organizationID: String

    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs._id == rhs._id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
}

