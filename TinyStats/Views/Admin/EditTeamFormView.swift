import SwiftUI
import FirebaseFirestore

struct EditTeamFormView: View {
    let team: Team
    var onDismiss: () -> Void

    @State private var name: String
    @State private var ageGroup: String
    @State private var playerCount: String
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss

    init(team: Team, onDismiss: @escaping () -> Void) {
        self.team = team
        self.onDismiss = onDismiss
        _name = State(initialValue: team.name)
        _ageGroup = State(initialValue: team.ageGroup)
        _playerCount = State(initialValue: String(team.playerCount))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Team Info")) {
                    TextField("Team Name", text: $name)
                    TextField("Age Group", text: $ageGroup)
                    TextField("Player Count", text: $playerCount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Team")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { updateTeam() }
                        .disabled(name.trimmed().isEmpty || ageGroup.trimmed().isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onDismiss() }
                }
            }
            if isSubmitting {
                ProgressView("Saving...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    .padding(.top, 8)
            } else if showSuccess {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Team updated!")
                        .foregroundColor(.green)
                }
                .font(.headline)
            }
        }
    }

    func updateTeam() {
        isSubmitting = true
        let db = Firestore.firestore()
        db.collection("teams").document(team.id).updateData([
            "name": name.trimmed(),
            "ageGroup": ageGroup.trimmed(),
            "playerCount": Int(playerCount.trimmed()) ?? 0
        ]) { error in
            isSubmitting = false
            if error == nil {
                showSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showSuccess = false
                    onDismiss()
                    dismiss()
                }
            }
            // Optionally handle error
        }
    }
}
