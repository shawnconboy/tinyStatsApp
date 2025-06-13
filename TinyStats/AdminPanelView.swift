import SwiftUI
import Firebase
import FirebaseFirestore

struct AdminPanelView: View {
    @StateObject var viewModel: AdminPanelViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var showAddTeam = false

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
                        HStack {
                            Text("Teams")
                                .font(.title3.bold())
                                .padding(.leading, 4)
                            Spacer()
                            // Only devs can add teams
                            if let role = auth.adminProfile?.role, role == "developer" {
                                Button(action: { showAddTeam = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                .accessibilityLabel("Add Team")
                            }
                        }

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
            .sheet(isPresented: $showAddTeam, onDismiss: { viewModel.fetchTeams() }) {
                AddTeamView(
                    organizationID: auth.adminProfile?.organizationID ?? "",
                    onAdd: { viewModel.fetchTeams(); showAddTeam = false }
                )
            }
        }
    }
}

// Helper extension for AdminPanelViewModel to fetch org name by ID
extension AdminPanelViewModel {
    func organizationName(for orgID: String) -> String? {
        guard !orgID.isEmpty else { return nil }
        if orgID.lowercased().contains("duncan") {
            return "Duncan YMCA"
        }
        return nil
    }
}

// --- Add this new view for devs to add a team ---

struct AddTeamView: View {
    let organizationID: String
    let onAdd: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var teamName: String = ""
    @State private var ageGroup: String = ""
    @State private var sport: String = ""
    @State private var coachID: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("Team Name")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Red Rockets", text: $teamName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)

                            Text("Age Group")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            TextField("U10", text: $ageGroup)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)

                            Text("Sport")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            TextField("Soccer", text: $sport)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)

                            Text("Coach ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            TextField("dev_shawnC_duncanYmca_001", text: $coachID)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 6)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    Button(action: addTeam) {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Add Team")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(isSubmitting ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(.plain)
                    .disabled(isSubmitting || teamName.isEmpty || ageGroup.isEmpty || sport.isEmpty || coachID.isEmpty)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Team")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addTeam() {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = ""

        let db = Firestore.firestore()
        let teamDoc = db.collection("teams").document()
        let teamID = teamDoc.documentID

        let teamData: [String: Any] = [
            "name": teamName,
            "ageGroup": ageGroup,
            "organizationID": organizationID,
            "sport": sport,
            "coachIDs": [coachID]
        ]

        teamDoc.setData(teamData) { err in
            isSubmitting = false
            if let err = err {
                errorMessage = err.localizedDescription
            } else {
                onAdd()
                dismiss()
            }
        }
    }
}
