import SwiftUI
import FirebaseFirestore

struct EditOrgFormView: View {
    let org: Organization
    var onDismiss: () -> Void

    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Organization Name")) {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Edit Organization")
            .onAppear { name = org.name }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { updateOrg() }
                        .disabled(name.trimmed().isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onDismiss() }
                }
            }
        }
    }

    func updateOrg() {
        let db = Firestore.firestore()
        db.collection("organizations").document(org.id).updateData(["name": name.trimmed()]) { error in
            if error == nil {
                onDismiss()
            } else {
                // Optional: handle error with alert
            }
        }
    }
}
