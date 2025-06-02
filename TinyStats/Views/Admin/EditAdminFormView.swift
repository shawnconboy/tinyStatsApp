import SwiftUI
import FirebaseFirestore

struct EditAdminFormView: View {
    let admin: UserRecord
    let orgID: String
    var onComplete: () -> Void

    @State private var email: String
    @State private var teamID: String
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss

    init(admin: UserRecord, orgID: String, onComplete: @escaping () -> Void) {
        self.admin = admin
        self.orgID = orgID
        self.onComplete = onComplete
        _email = State(initialValue: admin.email)
        _teamID = State(initialValue: admin.teamID)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 18) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 54)
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                    Text("Edit admin")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                }
                .padding(.top, 16)
                .padding(.bottom, 6)

                VStack(spacing: 18) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .autocapitalization(.none)
                    TextField("Team ID", text: $teamID)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .autocapitalization(.none)
                }
                .padding(.horizontal, 12)

                if isSubmitting {
                    ProgressView("Saving...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding(.top, 8)
                } else if showSuccess {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Admin updated!")
                            .foregroundColor(.green)
                    }
                    .font(.headline)
                }

                Button {
                    isSubmitting = true
                    let db = Firestore.firestore()
                    db.collection("users").document(admin.id).updateData([
                        "email": email,
                        "teamID": teamID
                    ]) { error in
                        isSubmitting = false
                        if error == nil {
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showSuccess = false
                                onComplete()
                                dismiss()
                            }
                        }
                        // Optionally handle error
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save Changes")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty || teamID.isEmpty ? Color(.systemGray4) : Color.accentColor)
                    .foregroundColor((email.isEmpty || teamID.isEmpty) ? .gray : .white)
                    .cornerRadius(12)
                }
                .disabled(email.isEmpty || teamID.isEmpty || isSubmitting)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Edit Admin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
