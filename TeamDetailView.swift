import SwiftUI

struct TeamDetailView: View {
    let team: Team
    @StateObject private var viewModel = TeamDetailViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(team.name)
                .font(.largeTitle)
                .padding(.top)

            // Coaches Section
            Text("Coaches")
                .font(.headline)
            if viewModel.coaches.isEmpty {
                Text("No coaches found.")
            } else {
                ForEach(viewModel.coaches) { coach in
                    Text(coach.name)
                }
            }

            // Members Section
            Text("Members")
                .font(.headline)
            if viewModel.members.isEmpty {
                Text("No members found.")
            } else {
                ForEach(viewModel.members) { member in
                    Text(member.name)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchCoaches(for: team)
            viewModel.fetchMembers(for: team)
        }
    }
}
