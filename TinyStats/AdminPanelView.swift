import SwiftUI

struct AdminPanelView: View {
    @StateObject var viewModel: AdminPanelViewModel
    @EnvironmentObject var auth: AuthViewModel

    init(auth: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: AdminPanelViewModel(auth: auth))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                        Text("Manage your organization, teams, and requests.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    // Organization Name Heading (use formatted name from Firestore)
                    if let orgID = auth.adminProfile?.organizationID,
                       let orgName = viewModel.organizationName(for: orgID), !orgName.isEmpty {
                        HStack {
                            Spacer()
                            Text(orgName)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.accentColor)
                                .padding(.vertical, 4)
                            Spacer()
                        }
                    }

                    // Teams Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Teams")
                            .font(.title3.bold())
                            .padding(.leading, 4)

                        ForEach(viewModel.teams) { team in
                            NavigationLink(destination: TeamDetailView(team: team)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(team.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Age Group: \(team.ageGroup)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Admin Hub")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Helper extension for AdminPanelViewModel to fetch org name by ID
extension AdminPanelViewModel {
    func organizationName(for orgID: String) -> String? {
        // Defensive: Ensure orgID is not empty and is a String
        guard !orgID.isEmpty else { return nil }
        // TEMP: fallback to hardcoded for demo
        if orgID.lowercased().contains("duncan") {
            return "Duncan YMCA"
        }
        // Add more mappings as needed
        return nil
    }
}
