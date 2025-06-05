import SwiftUI

struct AdminPanelView: View {
    @StateObject var viewModel: AdminPanelViewModel

    init(auth: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: AdminPanelViewModel(auth: auth))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Teams")
                        .font(.title.bold())
                        .padding(.horizontal)

                    ForEach(viewModel.teams) { team in
                        NavigationLink(destination: TeamDetailView(team: team)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(team.name)
                                        .font(.headline)
                                    Text("Age Group: \(team.ageGroup)")
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Admin")
        }
    }
}
