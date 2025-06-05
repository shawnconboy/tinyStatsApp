import SwiftUI
import FirebaseFirestore

struct EditAdminView: View {
    @Environment(\.dismiss) var dismiss

    var admin: Admin
    @Binding var refresh: () -> Void

    @State private var name: String
    @State private var email: String
    @State private var role: String

    init(admin: Admin, refresh: Binding<() -> Void>) {
        self.admin = admin
        _refresh = refresh
        _name = State(initialValue: admin.name)
        _email = State(initialValue: admin.email ?? "")  // ✅ Fixed optional
        _role = State(initialValue: admin.role ?? "admin")  // ✅ Fixed optional
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
            }
            .navigationTitle("Edit Admin")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func updateAdmin() {
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
}
