import SwiftUI
import FirebaseFirestore

struct TeamMembersManager: View {
    let team: Team
    @State private var members: [UserRecord] = []
    @State private var isLoading = true
    @State private var showAddMember = false
    @State private var selectedMember: UserRecord? = nil
    @State private var showEditMember = false
    @State private var showDeleteAlert = false
    @State private var memberToDelete: UserRecord? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView("Loading members...")
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                HStack {
                    Text("Team Members (\(members.count))")
                        .font(.title3.bold())
                    Spacer()
                    Button(action: { showAddMember = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.bottom, 2)

                if members.isEmpty {
                    Text("No members yet.")
                        .foregroundColor(.secondary)
                } else {
                    renderMemberList()
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear(perform: fetchMembers)
        .sheet(isPresented: $showAddMember) {
            AddMemberFormView(team: team) {
                showAddMember = false
                fetchMembers()
            }
        }
        .sheet(isPresented: $showEditMember, onDismiss: { selectedMember = nil }) {
            if let member = selectedMember {
                EditMemberFormView(member: member, team: team) {
                    showEditMember = false
                    fetchMembers()
                }
            }
        }
        .alert("Delete Member?", isPresented: $showDeleteAlert, presenting: memberToDelete) { member in
            Button("Delete", role: .destructive) {
                deleteMember(member)
            }
            Button("Cancel", role: .cancel) {}
        } message: { member in
            let displayName = (member.name?.isEmpty == false) ? member.name! : member.email
            Text("Are you sure you want to remove \(displayName)?")
        }
    }

    @ViewBuilder
    private func renderMemberList() -> some View {
        ForEach(members) { member in
            let displayName = (member.name?.isEmpty == false) ? member.name! : member.email

            HStack {
                Button(action: {
                    selectedMember = member
                    showEditMember = true
                }) {
                    HStack {
                        Text(displayName)
                            .font(.body)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(.plain)

                Button(action: {
                    memberToDelete = member
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 6)
        }
    }

    private func fetchMembers() {
        let db = Firestore.firestore()
        isLoading = true
        db.collection("users")
            .whereField("teamID", isEqualTo: team.id)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    let fetched = docs.map { doc in
                        UserRecord(
                            id: doc.documentID,
                            email: doc["email"] as? String ?? "(no email)",
                            teamID: doc["teamID"] as? String ?? "-",
                            name: doc["name"] as? String
                        )
                    }
                    DispatchQueue.main.async {
                        self.members = fetched.sorted { $0.email < $1.email }
                        db.collection("teams").document(team.id).updateData(["playerCount": self.members.count])
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
    }

    private func deleteMember(_ member: UserRecord) {
        let db = Firestore.firestore()
        db.collection("users").document(member.id).delete { error in
            if error == nil {
                fetchMembers()
            }
        }
    }

    struct AddMemberFormView: View {
        let team: Team
        var onComplete: () -> Void
        @State private var email = ""

        var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("New Member Email")) {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                    }
                }
                .navigationTitle("Add Member")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addMember()
                        }.disabled(email.isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onComplete() }
                    }
                }
            }
        }

        private func addMember() {
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "email": email,
                "teamID": team.id,
                "orgID": team.orgID,
                "role": "player",
                "isApproved": true,
                "status": "approved"
            ]
            db.collection("users").addDocument(data: userData) { error in
                onComplete()
            }
        }
    }

    struct EditMemberFormView: View {
        let member: UserRecord
        let team: Team
        var onComplete: () -> Void
        @State private var email: String

        init(member: UserRecord, team: Team, onComplete: @escaping () -> Void) {
            self.member = member
            self.team = team
            self.onComplete = onComplete
            _email = State(initialValue: member.email)
        }

        var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("Member Email")) {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                    }
                }
                .navigationTitle("Edit Member")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            updateMember()
                        }.disabled(email.isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onComplete() }
                    }
                }
            }
        }

        private func updateMember() {
            let db = Firestore.firestore()
            db.collection("users").document(member.id).updateData(["email": email]) { error in
                onComplete()
            }
        }
    }
}
