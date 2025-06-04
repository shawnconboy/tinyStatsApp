import SwiftUI
import FirebaseFirestore

struct AddOrganizationFormView: View {
    @State private var name: String = ""
    @State private var city: String = ""
    @State private var state: String = ""

    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Organization Details")) {
                    TextField("Name", text: $name)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                }
            }
            .navigationTitle("Add Organization")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addOrganization()
                    }
                    .disabled(name.isEmpty || city.isEmpty || state.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        onComplete()
                    }
                }
            }
        }
    }

    private func addOrganization() {
        let db = Firestore.firestore()
        let newOrg = [
            "name": name,
            "city": city,
            "state": state
        ]

        db.collection("organizations").addDocument(data: newOrg) { error in
            if let error = error {
                print("❌ Failed to add organization: \(error.localizedDescription)")
            }
            onComplete()
        }
    }
}
