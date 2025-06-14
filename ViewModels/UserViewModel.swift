import Foundation

class UserViewModel: ObservableObject {
    @Published var user: User
    // ...existing code...

    func updateTeamID(_ newTeamID: String) {
        user.teamID = newTeamID
        // Add any additional logic to refresh data, save to backend, etc.
    }

    // ...existing code...
}