import SwiftUI

struct TeamDetailView: View {
    let team: Team
    @StateObject private var viewModel = TeamDetailViewModel(teamID: "")

    init(team: Team) {
        self.team = team
        _viewModel = StateObject(wrappedValue: TeamDetailViewModel(teamID: team._id))
    }

    var body: some View {
        List {
            Section(header: Text("Team Members")) {
                ForEach(viewModel.members) { member in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(member.childName)
                                .font(.headline)
                            Text(member.parentName)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text("#\(member.jerseyNumber)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
