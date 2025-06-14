import Foundation

struct Team: Identifiable, Codable {
    var id: String
    var name: String
    var coachIDs: [String]?
    var memberIDs: [String]?
    // ...existing code...
}