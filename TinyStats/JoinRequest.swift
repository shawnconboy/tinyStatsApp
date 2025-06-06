import Foundation

struct JoinRequest: Identifiable {
    let id: String
    let parentName: String
    let childName: String
    let email: String
    let teamID: String
    let status: String
    let uid: String
}
