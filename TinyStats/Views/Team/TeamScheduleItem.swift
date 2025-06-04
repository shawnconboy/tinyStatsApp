import Foundation
import FirebaseFirestoreSwift

struct TeamScheduleItem: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var type: String  // "Game" or "Practice"
    var opponent: String?
    var time: String
    var location: String
    var snackParent: String?
    var notes: String?
}
