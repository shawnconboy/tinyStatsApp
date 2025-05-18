import SwiftUI

struct AddAdminFormView: View {
    let org: Organization
    var onComplete: () -> Void

    @State private var email = ""
    @State private var teamID = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Admin Details")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Team ID", text: $teamID)
                }

                Button("Add Admin") {
                    // TODO: Add to Firestore
                    onComplete()
                }
                .disabled(email.isEmpty || teamID.isEmpty)
            }
            .navigationTitle("Add Admin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        onComplete()
                    }
                }
            }
        }
    }
}
