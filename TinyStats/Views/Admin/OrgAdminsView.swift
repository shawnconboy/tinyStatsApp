import SwiftUI
import FirebaseFirestore

struct OrgAdminsView: View {
    let orgID: String
    let onAdd: () -> Void
    @State private var admins: [UserRecord] = []
    @State private var selectedAdmin: UserRecord? = nil
    @State private var showDeleteAlert = false
    @State private var adminToDelete: UserRecord? = nil

    private func initials(for email: String) -> String {
        let parts = email.split(separator: "@")
        if let name = parts.first, name.count > 1 {
            return name.prefix(2).uppercased()
        } else if let name = parts.first {
            return name.prefix(1).uppercased()
        }
        return "A"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Org Admins", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.title3.bold())
                Spacer()
                Button(action: onAdd) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Admin")
                    }
                    .font(.body.bold())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.accentColor.opacity(0.13))
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
                }
                .padding(.trailing, 8)
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 16)

            if admins.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No admins yet.")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 16)
            } else {
                ForEach(admins) { admin in
                    HStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.18))
                                .frame(width: 38, height: 38)
                            Text(initials(for: admin.email))
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(admin.email)
                                .font(.body.weight(.semibold))
                            Text("Team: \(admin.teamID)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            selectedAdmin = admin
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .padding(10)
                                .background(Color.blue.opacity(0.10))
                                .clipShape(Circle())
                        }
                        Button(action: {
                            adminToDelete = admin
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(10)
                                .background(Color.red.opacity(0.10))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6).opacity(0.7))
                    .cornerRadius(12)
                    .padding(.vertical, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .onAppear(perform: fetchAdmins)
        .sheet(item: $selectedAdmin, onDismiss: { selectedAdmin = nil }) { admin in
            EditAdminFormView(admin: admin, orgID: orgID) {
                selectedAdmin = nil
                fetchAdmins()
            }
        }
        .alert("Delete Admin?", isPresented: $showDeleteAlert, presenting: adminToDelete) { admin in
            Button("Delete", role: .destructive) {
                deleteAdmin(admin)
            }
            Button("Cancel", role: .cancel) {}
        } message: { admin in
            Text("Are you sure you want to remove \(admin.email) as an admin?")
        }
    }

    private func deleteAdmin(_ admin: UserRecord) {
        let db = Firestore.firestore()
        db.collection("users").document(admin.id).delete { error in
            if error == nil {
                fetchAdmins()
            }
            // Optionally handle error
        }
    }

    func fetchAdmins() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("orgID", isEqualTo: orgID)
            .whereField("role", isEqualTo: "admin")
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
                        self.admins = fetched.sorted { $0.email < $1.email }
                    }
                }
            }
    }
}
