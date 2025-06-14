import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var role: String
}