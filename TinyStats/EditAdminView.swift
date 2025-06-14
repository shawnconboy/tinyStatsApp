import SwiftUI
import FirebaseFirestore

struct EditAdminView: View {
    @Environment(\.dismiss) var dismiss

    var admin: Admin
    var refresh: () -> Void

    @State private var name: String
    @State private var email: String
    @State private var role: String

    init(admin: Admin, refresh: @escaping () -> Void) {
        self.admin = admin
        self.refresh = refresh
        _name = State(initialValue: admin.name)
        _email = State(initialValue: admin.email ?? "")
        _role = State(initialValue: admin.role ?? "admin")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Admin Info")) {
                    TextField("Name", text: $name)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Picker("Role", selection: $role) {
                        Text("admin").tag("admin")
                        Text("developer").tag("developer")
                    }
                }

                Section {
                    Button("Save Changes") {
                        updateAdmin()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        deleteAdmin()
                    } label: {
                        Label("Delete Admin", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Admin")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func updateAdmin() {
        let db = Firestore.firestore()
        db.collection("admins").document(admin._id).updateData([
            "name": name,
            "email": email,
            "role": role
        ]) { error in
            if let error = error {
                print("Error updating admin: \(error.localizedDescription)")
            } else {
                refresh()
                dismiss()
            }
        }
    }

    private func deleteAdmin() {
        let db = Firestore.firestore()
        db.collection("admins").document(admin._id).delete { error in
            if let error = error {
                print("Error deleting admin: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    refresh()
                    dismiss()
                }
            }
        }
    }
}
