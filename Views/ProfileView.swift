import SwiftUI

struct ProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var showChangeTeamAlert = false
    @State private var newTeamID = ""

    var body: some View {
        VStack {
            // ...existing code...

            if userViewModel.user.role == .dev {
                Button("Change Team") {
                    showChangeTeamAlert = true
                }
                .alert("Enter New Team ID", isPresented: $showChangeTeamAlert, actions: {
                    TextField("Team ID", text: $newTeamID)
                    Button("OK") {
                        userViewModel.updateTeamID(newTeamID)
                        newTeamID = ""
                    }
                    Button("Cancel", role: .cancel) {
                        newTeamID = ""
                    }
                })
            }

            // ...existing code...
        }
    }
}