import SwiftUI
import FirebaseFirestore

struct AddTeamFormView: View {
    let org: Organization
    var onDismiss: () -> Void

    @State private var name = ""
    @State private var ageGroup = ""
    @State private var playerCount = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Team Info")) {
                    TextField("Team Name", text: $name)
                    TextField("Age Group", text: $ageGroup)
                    TextField("Estimated Player Count", text: $playerCount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Team")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { addTeam() }
                        .disabled(name.trimmed().isEmpty || ageGroup.trimmed().isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onDismiss() }
                }
            }
        }
    }

    func addTeam() {
        let db = Firestore.firestore()
        let teamData: [String: Any] = [
            "name": name.trimmed(),
            "ageGroup": ageGroup.trimmed(),
            "playerCount": Int(playerCount.trimmed()) ?? 0,
            "orgID": org.id
        ]
        db.collection("teams").addDocument(data: teamData) { error in
            if error == nil {
                onDismiss()
            } else {
                // Optional: handle error with alert
            }
        }
    }
}

