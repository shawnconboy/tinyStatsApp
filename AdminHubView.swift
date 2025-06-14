import SwiftUI

struct AdminHubView: View {
    @ObservedObject var viewModel: AdminHubViewModel

    var body: some View {
        NavigationView {
            List(viewModel.teams) { team in
                NavigationLink(destination: TeamDetailView(team: team)) {
                    Text(team.name)
                }
            }
            .navigationTitle("Teams")
        }
    }
}