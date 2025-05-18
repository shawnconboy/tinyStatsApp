import SwiftUI
import FirebaseFirestore

struct OrgAdminsView: View {
    let orgID: String
    let onAdd: () -> Void
    @State private var admins: [UserRecord] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Org Admins")
                    .font(.subheadline.bold())
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                }
            }

            if admins.isEmpty {
                Text("No admins yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(admins) { admin in
                    HStack {
                        Text("• \(admin.email) (\(admin.teamID))")
                        Spacer()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            // TODO: Delete admin
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            // TODO: Edit admin
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchAdmins)
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
                            teamID: doc["teamID"] as? String ?? "-"
                        )
                    }
                    DispatchQueue.main.async {
                        self.admins = fetched.sorted { $0.email < $1.email }
                    }
                }
            }
    }
}
