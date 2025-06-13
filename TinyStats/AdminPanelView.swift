import SwiftUI
import Firebase
import FirebaseFirestore

struct AdminPanelView: View {
    @StateObject var viewModel: AdminPanelViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var showAddTeam = false
    @State private var showCreateCoach = false
    @State private var isRefreshing = false // <-- NEW

    init(auth: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: AdminPanelViewModel(auth: auth))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                // --- Add pull-to-refresh using SwiftUI's refreshable (iOS 15+) ---
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

                    HStack {
                        Spacer()
                        // Only devs can add coaches
                        if let role = auth.adminProfile?.role, role == "developer" {
                            Button(action: { showCreateCoach = true }) {
                                Label("Create Coach", systemImage: "person.crop.circle.badge.plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        Spacer()
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
            .refreshable {
                isRefreshing = true
                viewModel.fetchTeams()
                viewModel.fetchAdmins()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isRefreshing = false
                }
            }
            .navigationTitle("Admin Hub")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddTeam, onDismiss: { viewModel.fetchTeams() }) {
                AddTeamView(
                    organizationID: auth.adminProfile?.organizationID ?? "",
                    admins: viewModel.admins, // <-- pass admins
                    onAdd: { viewModel.fetchTeams(); showAddTeam = false }
                )
            }
            .sheet(isPresented: $showCreateCoach, onDismiss: { viewModel.fetchAdmins() }) {
                CreateCoachView(
                    organizationID: auth.adminProfile?.organizationID ?? "",
                    onCreated: { viewModel.fetchAdmins(); showCreateCoach = false }
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
    let admins: [Admin]
    let onAdd: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var teamName: String = ""
    @State private var ageGroup: String = ""
    @State private var sport: String = ""
    @State private var selectedCoachID: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String = ""

    // Dropdown options
    private let ageGroups = ["U6", "U8", "U10", "U12", "U14", "U16", "U18", "Adult"]
    private let sports = ["Soccer", "Basketball", "Baseball", "Softball", "Football", "Volleyball", "Hockey", "Other"]

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
                            Picker("Age Group", selection: $ageGroup) {
                                Text("Select Age Group").tag("")
                                ForEach(ageGroups, id: \.self) { group in
                                    Text(group).tag(group)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 6)

                            Text("Sport")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Picker("Sport", selection: $sport) {
                                Text("Select Sport").tag("")
                                ForEach(sports, id: \.self) { s in
                                    Text(s).tag(s)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 6)

                            Text("Coach")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Picker("Coach", selection: $selectedCoachID) {
                                ForEach(admins, id: \.id) { admin in
                                    Text("\(admin.name)\(admin.role != nil ? " (\(admin.role!))" : "")").tag(admin._id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 6)
                            .onAppear {
                                if selectedCoachID.isEmpty, let first = admins.first {
                                    selectedCoachID = first._id
                                }
                            }
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

                    // Make the button fill width, tappable, and dismiss keyboard on tap
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        addTeam()
                    }) {
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
                    .contentShape(Rectangle()) // Ensures the whole button area is tappable
                    .buttonStyle(.plain)
                    .disabled(isSubmitting || teamName.isEmpty || ageGroup.isEmpty || sport.isEmpty || selectedCoachID.isEmpty)

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

        // Generate structured team ID (e.g., team_redRockets_duncanYmca_001)
        let formattedTeamName = teamName.replacingOccurrences(of: " ", with: "")
        let baseID = "team_\(formattedTeamName)_\(organizationID)_"
        db.collection("teams")
            .whereField("organizationID", isEqualTo: organizationID)
            .getDocuments { snapshot, _ in
                let similarIDs = snapshot?.documents.map { $0.documentID }
                    .filter { $0.hasPrefix(baseID) } ?? []
                let nextNumber = similarIDs.count + 1
                let formattedNumber = String(format: "%03d", nextNumber)
                let structuredTeamID = baseID + formattedNumber

                let teamData: [String: Any] = [
                    "name": teamName,
                    "ageGroup": ageGroup,
                    "organizationID": organizationID,
                    "sport": sport,
                    "coachIDs": selectedCoachID.isEmpty ? [] : [selectedCoachID]
                ]

                // Use the structuredTeamID as the document ID
                db.collection("teams").document(structuredTeamID).setData(teamData) { err in
                    if let err = err {
                        isSubmitting = false
                        errorMessage = err.localizedDescription
                    } else {
                        // Assign the structured team ID to the coach's teamID field
                        if !selectedCoachID.isEmpty {
                            db.collection("admins").document(selectedCoachID).updateData([
                                "teamID": structuredTeamID
                            ]) { updateErr in
                                if let updateErr = updateErr {
                                    print("Error updating coach's teamID: \(updateErr.localizedDescription)")
                                }
                                isSubmitting = false
                                onAdd()
                                dismiss()
                            }
                        } else {
                            isSubmitting = false
                            onAdd()
                            dismiss()
                        }
                    }
                }
            }
    }
}

// --- NEW: CreateCoachView ---

struct CreateCoachView: View {
    let organizationID: String
    let onCreated: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Coach Info")) {
                    TextField("Full Name", text: $name)
                        .autocapitalization(.words)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                Button(isSubmitting ? "Creating..." : "Create Coach") {
                    createCoach()
                }
                .disabled(isSubmitting || name.isEmpty || email.isEmpty || password.isEmpty)
            }
            .navigationTitle("Create Coach")
        }
    }

    private func createCoach() {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = ""

        // Generate structured document ID
        let nameParts = name.split(separator: " ")
        let firstName = nameParts.first?.lowercased() ?? "coach"
        let lastInitial = nameParts.dropFirst().first?.prefix(1).capitalized ?? "X"
        let formattedName = "\(firstName)\(lastInitial)"
        let orgID = organizationID
        let baseID = "coach_\(formattedName)_\(orgID)_"

        // Create Firebase Auth user
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isSubmitting = false
                return
            }
            guard let uid = result?.user.uid else {
                self.errorMessage = "Failed to create user."
                self.isSubmitting = false
                return
            }
            
            // Find next available coach number
            let db = Firestore.firestore()
            db.collection("admins")
                .whereField("organizationID", isEqualTo: orgID)
                .whereField("role", isEqualTo: "coach")
                .getDocuments { snapshot, _ in
                    let similarIDs = snapshot?.documents.map { $0.documentID }
                        .filter { $0.hasPrefix(baseID) } ?? []
                    let nextNumber = similarIDs.count + 1
                    let formattedNumber = String(format: "%03d", nextNumber)
                    let docID = baseID + formattedNumber
                    
                    let adminData: [String: Any] = [
                        "name": name,
                        "email": email,
                        "uid": uid,
                        "organizationID": orgID,
                        "role": "coach"
                    ]
                    db.collection("admins").document(docID).setData(adminData) { err in
                        self.isSubmitting = false
                        if let err = err {
                            self.errorMessage = err.localizedDescription
                        } else {
                            onCreated()
                            dismiss()
                        }
                    }
                }
        }
    }
}
