import Foundation

struct Event: Identifiable, Equatable, Hashable {
    var id: String { _id }
    let _id: String
    let teamAName: String
    let teamBName: String
    let snackVolunteerID: String?
    let snackVolunteerName: String?
    let eventDate: Date
    let title: String
    let location: String
    let note: String

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs._id == rhs._id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
}
