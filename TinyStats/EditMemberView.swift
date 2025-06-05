import SwiftUI
import FirebaseFirestore

struct EditMemberView: View {
    @Environment(\.dismiss) var dismiss

    var member: Member
    var refresh: () -> Void

    @State private var parentName: String
    @State private var childName: String
    @State private var jerseyNumber: String

    init(member: Member, refresh: @escaping () -> Void) {
        self.member = member
        self.refresh = refresh
        _parentName = State(initialValue: member.parentName)
        _childName = State(initialValue: member.childName)
        _jerseyNumber = State(initialValue: String(member.jerseyNumber))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Member Info")) {
                    TextField("Parent Name", text: $parentName)
                    TextField("Child Name", text: $childName)
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("Save Changes") {
                        updateMember()
                    }
                }
            }
            .navigationTitle("Edit Member")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func updateMember() {
        let db = Firestore.firestore()
        db.collection("members").document(member._id).updateData([
            "name": parentName,
            "childName": childName,
            "playerNumber": Int(jerseyNumber) ?? 0
        ]) { error in
            if let error = error {
                print("Error updating member: \(error.localizedDescription)")
            } else {
                refresh()
                dismiss()
            }
        }
    }
}
